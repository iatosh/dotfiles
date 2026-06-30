'use strict';

// 文字 index → {line, column}（1始まり）変換のための行頭オフセット表。
function buildLineStarts(text) {
  const starts = [0];
  for (let i = 0; i < text.length; i++) {
    if (text[i] === '\n') starts.push(i + 1);
  }
  return starts;
}

function lineOf(lineStarts, index) {
  let lo = 0, hi = lineStarts.length - 1, line = 0;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1;
    if (lineStarts[mid] <= index) { line = mid; lo = mid + 1; }
    else hi = mid - 1;
  }
  return line; // 0-based line index
}

function posFromIndex(lineStarts, index) {
  const l = lineOf(lineStarts, index);
  return { line: l + 1, column: index - lineStarts[l] + 1 };
}

// 日本語文字（ひらがな・カタカナ・漢字）を含むか
const JP_CHAR = /[぀-ヿ㐀-鿿々〆ヶ]/;

module.exports = { buildLineStarts, lineOf, posFromIndex, JP_CHAR };
