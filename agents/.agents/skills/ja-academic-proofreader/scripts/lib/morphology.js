'use strict';

// 形態素解析（kuromoji）による検出:
//   S-05 連用形（連用中止法）: 動詞の連用形 + 読点（、，）
//   S-07 受動態: 助動詞「れる/られる」
const path = require('path');
const fs = require('fs');
const kuromoji = require('kuromoji');

let _tokenizer = null;

function resolveDicPath() {
  const main = require.resolve('kuromoji'); // .../kuromoji/src/kuromoji.js
  const candidates = [
    path.join(path.dirname(main), '..', 'dict'),
    path.join(path.dirname(main), 'dict'),
    path.join(process.cwd(), 'node_modules', 'kuromoji', 'dict'),
  ];
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  return candidates[0];
}

function getTokenizer() {
  if (_tokenizer) return Promise.resolve(_tokenizer);
  return new Promise((resolve, reject) => {
    kuromoji.builder({ dicPath: resolveDicPath() }).build((err, tokenizer) => {
      if (err) return reject(err);
      _tokenizer = tokenizer;
      resolve(tokenizer);
    });
  });
}

async function analyze(text) {
  const tokenizer = await getTokenizer();
  const tokens = tokenizer.tokenize(text);
  const findings = [];

  for (let i = 0; i < tokens.length; i++) {
    const tk = tokens[i];
    const index = (tk.word_position || 1) - 1; // word_position は1始まりの文字位置

    // S-07 受動態（助動詞「れる/られる」。IPADICでは pos=動詞 となるため品詞非依存で判定。
    // 可能・自発・尊敬との区別は文脈依存のため LLM 層に委ねる＝S-soft warning）
    if ((tk.pos === '助動詞' || tk.pos === '動詞') && (tk.basic_form === 'れる' || tk.basic_form === 'られる')) {
      const prev = tokens[i - 1];
      const next = tokens[i + 1];
      findings.push({
        ruleId: 'S-07',
        severity: 'warning',
        index,
        message: '受動態は極力避け、主語を明確にして能動態に（ただし「既存の定義への言及」等は正用＝L-24）',
        excerpt: (prev ? prev.surface_form : '') + tk.surface_form + (next ? next.surface_form : ''),
      });
    }

    // S-05 連用中止法: 用言（動詞、または「である」の助動詞ある）の連用形 + 読点
    // 「〜し、」（動詞・サ変）と「〜であり、」（助動詞ある）の両方を捕捉する。
    const isRenyo = /^連用/.test(tk.conjugated_form || '');
    const isYogen = tk.pos === '動詞' || (tk.pos === '助動詞' && tk.basic_form === 'ある');
    if (isYogen && isRenyo) {
      const next = tokens[i + 1];
      if (next && (next.surface_form === '、' || next.surface_form === '，')) {
        const prev = tokens[i - 1];
        findings.push({
          ruleId: 'S-05',
          severity: 'warning',
          index,
          message: '連用形（〜し/〜であり等）は前後の接続関係を曖昧にする。明示的接続（〜した後/〜のため）か、主語を変えた主述文に',
          excerpt: (prev ? prev.surface_form : '') + tk.surface_form + next.surface_form,
        });
      }
    }
  }
  return findings;
}

module.exports = { analyze, getTokenizer };
