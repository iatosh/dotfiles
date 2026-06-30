#!/usr/bin/env node
'use strict';

// 静的層の回帰テスト。cases.jsonl の各ケースを proofread() に通し、
// expect_fire（該当ルールが発火すべきか）と実際の発火を突き合わせる。
const fs = require('fs');
const path = require('path');
const { proofread } = require('../../scripts/proofread.js');

async function run() {
  const file = path.join(__dirname, 'cases.jsonl');
  const lines = fs.readFileSync(file, 'utf8').split('\n').filter((l) => l.trim());
  let pass = 0;
  const failures = [];

  for (const line of lines) {
    const c = JSON.parse(line);
    const type = c.type || null;
    const fname = type === 'latex' ? 'case.tex' : 'case.md';
    const res = await proofread(c.text, { file: fname, type });
    const fired = res.findings.some((f) => f.ruleId === c.rule);
    if (fired === c.expect_fire) pass++;
    else failures.push({ ...c, fired });
  }

  const total = lines.length;
  console.log(`\nstatic tests: ${pass}/${total} passed, ${failures.length} failed`);
  for (const f of failures) {
    const snippet = f.text.slice(0, 44).replace(/\n/g, '⏎');
    console.log(`  FAIL #${f.id} [${f.rule}] expect_fire=${f.expect_fire} got=${f.fired}  «${snippet}»  (${f.note || ''})`);
  }
  process.exit(failures.length ? 1 : 0);
}

run().catch((e) => { console.error(e); process.exit(1); });
