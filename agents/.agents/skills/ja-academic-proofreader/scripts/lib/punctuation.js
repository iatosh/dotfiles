'use strict';

// S-14 言語モードと約物の半角/全角。severity は検出箇所（ここ）で持つ。
// 高精度な検出に絞る（細かな逸脱は LLM 層に委ねる）:
//   (1) 全角英数字 → 半角に（数式・英単語は英語モード＝半角）
//   (2) 日本語モードの半角丸かっこ () → 全角（）に
//       判定: 「直前の文字が日本語」または「中身に日本語を含む」なら日本語モード。
//       例「脳波(EEG)」「短時間(0.2s)」は直前が日本語なので対象。「ReLU(x)」は英語モードで対象外。
const { JP_CHAR } = require('./util');

const FULLWIDTH_ALNUM = /[Ａ-Ｚａ-ｚ０-９]+/g;
const HALF_PAREN = /\(([^()\n]*)\)/g;

function check(text) {
  const findings = [];
  let m;

  while ((m = FULLWIDTH_ALNUM.exec(text))) {
    findings.push({
      ruleId: 'S-14',
      severity: 'error',
      index: m.index,
      message: '全角英数字は半角に（数式・英単語は英語モード＝半角）',
      excerpt: m[0],
    });
  }

  while ((m = HALF_PAREN.exec(text))) {
    const content = m[1];
    const prev = m.index > 0 ? text[m.index - 1] : '';
    if (JP_CHAR.test(prev) || JP_CHAR.test(content)) {
      findings.push({
        ruleId: 'S-14',
        severity: 'error',
        index: m.index,
        message: '日本語モードの丸かっこは全角（）に（直前が日本語なら、中身が英語でも「（EEG）」のように括弧は全角）',
        excerpt: m[0].length > 24 ? m[0].slice(0, 24) + '…' : m[0],
      });
    }
  }

  return findings;
}

module.exports = { check };
