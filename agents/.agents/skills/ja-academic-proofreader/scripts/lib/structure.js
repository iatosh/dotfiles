'use strict';

// 構造系の検出:
//   S-16 「しかしながら/However」が同一セクションで複数回
//   S-17 1文だけの段落
//   S-18 節/小節が1つだけ
const { buildLineStarts, lineOf, JP_CHAR } = require('./util');

function parseHeadings(lines) {
  const heads = [];
  for (let i = 0; i < lines.length; i++) {
    const ln = lines[i];
    const md = ln.match(/^(#{1,6})\s+\S/);
    if (md) { heads.push({ level: md[1].length, line: i + 1 }); continue; }
    const tex = ln.match(/^\s*\\(subsubsection|subsection|section)\*?\s*[\{\[]/);
    if (tex) {
      const lvl = { section: 1, subsection: 2, subsubsection: 3 }[tex[1]];
      heads.push({ level: lvl, line: i + 1 });
    }
  }
  return heads;
}

// S-18: ある見出しの直下の子見出しが1つだけなら警告
function checkSubsections(heads) {
  const findings = [];
  for (let i = 0; i < heads.length; i++) {
    const h = heads[i];
    let childLevel = null, count = 0;
    for (let j = i + 1; j < heads.length; j++) {
      if (heads[j].level <= h.level) break;
      if (childLevel === null) childLevel = heads[j].level;
      if (heads[j].level === childLevel) count++;
    }
    if (count === 1) {
      findings.push({
        ruleId: 'S-18',
        severity: 'warning',
        line: h.line,
        column: 1,
        message: '節/小節が1つだけ。下位区分は2つ以上にする（項目が1つの箇条書きはありえないのと同じ）',
        excerpt: '',
      });
    }
  }
  return findings;
}

// S-17: 1文だけの段落
function checkParagraphs(text) {
  const findings = [];
  const parts = text.split(/\n[ \t]*\n/);
  let cursor = 0;
  for (const part of parts) {
    const start = text.indexOf(part, cursor);
    cursor = start + part.length;
    const trimmed = part.trim();
    if (!trimmed) continue;
    const firstLine = trimmed.split('\n')[0];
    // 見出し・コマンド・箇条書き・表・図表キャプション行などはスキップ
    if (/^(#{1,6}\s|\\|[-*+]\s|\d+[.)]\s|\||>|```)/.test(firstLine)) continue;
    if (!JP_CHAR.test(trimmed)) continue;
    if (trimmed.replace(/\s/g, '').length < 30) continue;
    const terminators = (trimmed.match(/[。．！？]/g) || []).length;
    if (terminators === 1) {
      findings.push({
        ruleId: 'S-17',
        severity: 'warning',
        index: start,
        message: '1文だけの段落。段落は2文以上で構成する',
        excerpt: firstLine.length > 30 ? firstLine.slice(0, 30) + '…' : firstLine,
      });
    }
  }
  return findings;
}

// S-16: 同一セクション内の「しかしながら/However」複数回
function checkHowever(text, heads, lineStarts) {
  const findings = [];
  const re = /しかしながら|(?<![A-Za-z])[Hh]owever/g;
  const occ = [];
  let m;
  while ((m = re.exec(text))) occ.push({ index: m.index, surface: m[0] });

  const headLines = heads.map((h) => h.line).sort((a, b) => a - b);
  function sectionOf(index) {
    const line = lineOf(lineStarts, index) + 1;
    let s = 0;
    for (const hl of headLines) { if (hl <= line) s = hl; else break; }
    return s;
  }

  const groups = new Map();
  for (const o of occ) {
    const s = sectionOf(o.index);
    if (!groups.has(s)) groups.set(s, []);
    groups.get(s).push(o);
  }
  for (const arr of groups.values()) {
    for (let k = 1; k < arr.length; k++) {
      findings.push({
        ruleId: 'S-16',
        severity: 'error',
        index: arr[k].index,
        message: '「しかしながら/However」は序論・概要で1回だけの切り札。同一セクションで複数回使わない（隠れしかしながら＝H-02も含めて）',
        excerpt: arr[k].surface,
      });
    }
  }
  return findings;
}

function check(text) {
  const lines = text.split('\n');
  const lineStarts = buildLineStarts(text);
  const heads = parseHeadings(lines);
  return [
    ...checkSubsections(heads),
    ...checkParagraphs(text),
    ...checkHowever(text, heads, lineStarts),
  ];
}

module.exports = { check, parseHeadings };
