'use strict';

// LaTeX ソース限定（.tex 検出時のみ呼ぶ）:
//   S-19 数式末尾の句読点（数式は言語）
//   S-20 式の前方引用（\label より前に \eqref/\ref）
//   S-21 figure は [t] オプション推奨
//   S-22 結果図はベクタ形式（png/jpg/bmp/gif/tiff 不可）
const { buildLineStarts, lineOf } = require('./util');

const RASTER_EXT = /\.(png|jpe?g|bmp|gif|tif?f)$/i;

function check(text) {
  const findings = [];
  const lineStarts = buildLineStarts(text);
  let m;

  // S-22 ラスタ画像
  const reInc = /\\includegraphics(?:\[[^\]]*\])?\{([^}]+)\}/g;
  while ((m = reInc.exec(text))) {
    const file = m[1].trim();
    if (RASTER_EXT.test(file)) {
      findings.push({
        ruleId: 'S-22',
        severity: 'error',
        index: m.index,
        message: `結果図はベクタ形式(pdf/eps/ps)を使う。「${file}」はビットマップ形式。PNGをPDFに変換するのではなく、savefig等で出力し直す`,
        excerpt: file,
      });
    }
  }

  // S-21 figure[t]
  const reFig = /\\begin\{figure\}(\*?)(\[[^\]]*\])?/g;
  while ((m = reFig.exec(text))) {
    const opt = m[2] || '';
    if (!/t/.test(opt)) {
      findings.push({
        ruleId: 'S-21',
        severity: 'warning',
        index: m.index,
        message: '図は \\begin{figure}[t]（tオプション）でページ上部に配置するのが論文の標準',
        excerpt: '\\begin{figure}' + m[1] + opt,
      });
    }
  }

  // S-20 式の前方引用
  const labels = new Map(); // name -> first line
  const reLabel = /\\label\{(eq:[^}]+)\}/g;
  while ((m = reLabel.exec(text))) {
    const name = m[1];
    const line = lineOf(lineStarts, m.index) + 1;
    if (!labels.has(name)) labels.set(name, line);
  }
  const reRef = /\\(?:eqref|ref)\{(eq:[^}]+)\}/g;
  while ((m = reRef.exec(text))) {
    const name = m[1];
    const refLine = lineOf(lineStarts, m.index) + 1;
    const defLine = labels.get(name);
    if (defLine !== undefined && refLine < defLine) {
      findings.push({
        ruleId: 'S-20',
        severity: 'error',
        index: m.index,
        message: `式の前方引用（定義 ${defLine}行目より前で参照）。読者を行き来させないため、式は定義後に引用する`,
        excerpt: name,
      });
    }
  }

  // S-19 数式末尾の句読点
  const reEnv = /\\begin\{(equation|align|gather|multline|eqnarray)\*?\}([\s\S]*?)\\end\{\1\*?\}/g;
  while ((m = reEnv.exec(text))) {
    const inner = m[2].replace(/%.*$/gm, '').trim();
    if (inner && !/[。．.,，]$/.test(inner.replace(/\\nonumber|\\\\$/g, '').trim())) {
      findings.push({
        ruleId: 'S-19',
        severity: 'warning',
        index: m.index,
        message: '数式は言語の一部。末尾に句読点（文中なら「,」、文末なら「.」）を付けるか確認する',
        excerpt: '\\begin{' + m[1] + '}',
      });
    }
  }
  const reBracket = /\\\[([\s\S]*?)\\\]/g;
  while ((m = reBracket.exec(text))) {
    const inner = m[1].trim();
    if (inner && !/[。．.,，]$/.test(inner)) {
      findings.push({
        ruleId: 'S-19',
        severity: 'warning',
        index: m.index,
        message: '数式は言語の一部。末尾に句読点（文中なら「,」、文末なら「.」）を付けるか確認する',
        excerpt: '\\[ … \\]',
      });
    }
  }

  return findings;
}

module.exports = { check };
