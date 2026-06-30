#!/usr/bin/env node
'use strict';

// ja-academic-proofreader 静的層エントリポイント。
// 使い方:
//   node scripts/proofread.js <file> [--type prose|latex] [--format json|pretty]
//   echo "テキスト" | node scripts/proofread.js --stdin [--type ...]
//
// textlint(prh) のフレーズ検出 + kuromoji 形態素 + 約物 + 構造 + LaTeX を統合する。
// 重大度（severity）は各ルールの定義場所が持つ:
//   - フレーズ系: scripts/prh-academic.yml の各エントリ（ruleId/severity）
//   - 形態素/約物/構造/LaTeX: 各 lib の検出箇所
// proofread.js は中央の ID→severity 表を持たない（ruleId は参考情報として出力するだけ）。

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');
const yaml = require('js-yaml');

const { buildLineStarts, posFromIndex } = require('./lib/util');
const morphology = require('./lib/morphology');
const punctuation = require('./lib/punctuation');
const structure = require('./lib/structure');
const latex = require('./lib/latex');

const SKILL_ROOT = path.join(__dirname, '..');
const PRH_PATH = path.join(__dirname, 'prh-academic.yml');

function parseArgs(argv) {
  const args = { file: null, type: null, format: 'json', stdin: false };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--type') args.type = argv[++i];
    else if (a === '--format') args.format = argv[++i];
    else if (a === '--stdin') args.stdin = true;
    else if (!a.startsWith('--')) args.file = a;
  }
  return args;
}

function detectType(file, content, override) {
  if (override) return override;
  if (file && /\.tex$/i.test(file)) return 'latex';
  if (/\\(documentclass|begin\{document\}|section\*?\{|includegraphics)/.test(content)) return 'latex';
  return 'prose';
}

// prh-academic.yml を読み、expected → {ruleId, severity} の対応を作る。
// textlint の prh メッセージは "<matched> => <expected>" 形式なので expected で逆引きできる。
let _prhMeta = null;
function loadPrhMeta() {
  if (_prhMeta) return _prhMeta;
  const map = new Map();
  try {
    const doc = yaml.load(fs.readFileSync(PRH_PATH, 'utf8'));
    for (const r of (doc && doc.rules) || []) {
      if (r && r.expected) {
        map.set(String(r.expected), { ruleId: r.ruleId || 'prh', severity: r.severity || 'warning' });
      }
    }
  } catch (_) { /* noop */ }
  _prhMeta = map;
  return map;
}

function runTextlintPrh(content) {
  const tmp = path.join(os.tmpdir(), `jap-${process.pid}-${Date.now()}.md`);
  fs.writeFileSync(tmp, content);
  const bin = path.join(SKILL_ROOT, 'node_modules', '.bin', 'textlint');
  try {
    if (!fs.existsSync(bin)) return { ok: false, messages: [], error: 'textlint未インストール（npm install を実行）' };
    let out = '';
    try {
      out = execFileSync(
        bin,
        ['-f', 'json', '-c', path.join(SKILL_ROOT, '.textlintrc.json'), '--no-color', tmp],
        { cwd: SKILL_ROOT, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }
      );
    } catch (e) {
      out = (e.stdout && e.stdout.toString()) || ''; // lint問題ありで exit 1
    }
    const arr = JSON.parse(out || '[]');
    return { ok: true, messages: arr.flatMap((r) => r.messages || []) };
  } catch (e) {
    return { ok: false, messages: [], error: String((e && e.message) || e) };
  } finally {
    try { fs.unlinkSync(tmp); } catch (_) { /* noop */ }
  }
}

// prh メッセージ "<matched> => <expected>" を {ruleId, severity, message, excerpt} に変換
function mapPrhMessages(messages) {
  const meta = loadPrhMeta();
  const out = [];
  for (const msg of messages) {
    const text = msg.message || '';
    const sep = text.indexOf(' => ');
    let matched = '';
    let expected = text;
    if (sep >= 0) {
      matched = text.slice(0, sep).replace(/^[「"']|[」"']$/g, '').trim();
      expected = text.slice(sep + 4).trim();
    }
    const m = meta.get(expected) || { ruleId: 'prh', severity: 'warning' };
    out.push({
      ruleId: m.ruleId,
      severity: m.severity,
      line: msg.line,
      column: msg.column,
      message: expected,
      excerpt: matched,
    });
  }
  return out;
}

function pushIndexed(findings, f, lineStarts) {
  const base = {
    ruleId: f.ruleId,
    severity: f.severity || 'warning',
    message: f.message,
    excerpt: f.excerpt || '',
  };
  if (f.line != null) {
    findings.push({ ...base, line: f.line, column: f.column || 1 });
  } else {
    const pos = posFromIndex(lineStarts, f.index);
    findings.push({ ...base, line: pos.line, column: pos.column });
  }
}

async function proofread(content, opts) {
  const inputType = detectType(opts.file, content, opts.type);
  const lineStarts = buildLineStarts(content);
  const findings = [];
  const notes = [];

  // 1) textlint(prh) フレーズ検出（severity は prh-academic.yml 由来）
  const prh = runTextlintPrh(content);
  if (!prh.ok) notes.push(prh.error);
  for (const f of mapPrhMessages(prh.messages)) {
    findings.push({ ruleId: f.ruleId, severity: f.severity, line: f.line, column: f.column, message: f.message, excerpt: f.excerpt });
  }

  // 2) 形態素（S-05 連用形 / S-07 受動態）
  try {
    for (const f of await morphology.analyze(content)) pushIndexed(findings, f, lineStarts);
  } catch (e) {
    notes.push('形態素解析に失敗: ' + ((e && e.message) || e));
  }

  // 3) 約物 S-14 / 4) 構造 S-16/17/18
  for (const f of punctuation.check(content)) pushIndexed(findings, f, lineStarts);
  for (const f of structure.check(content)) pushIndexed(findings, f, lineStarts);

  // 5) LaTeX S-19〜22（.tex のみ）
  if (inputType === 'latex') {
    for (const f of latex.check(content)) pushIndexed(findings, f, lineStarts);
  }

  findings.sort((a, b) => (a.line - b.line) || (a.column - b.column) || a.ruleId.localeCompare(b.ruleId));

  const summary = { error: 0, warning: 0 };
  for (const f of findings) summary[f.severity] = (summary[f.severity] || 0) + 1;

  return {
    file: opts.file || '(stdin)',
    inputType,
    layer: 'static',
    note: '文脈依存ルール（S-softの精査・H・L）は LLM 層で判定する。これは静的層のみの結果。',
    diagnostics: notes,
    summary,
    findings,
  };
}

function pretty(result) {
  const lines = [];
  lines.push(`# 静的添削レポート (${result.inputType})  error:${result.summary.error} warning:${result.summary.warning}`);
  if (result.diagnostics.length) lines.push('  ⚠ ' + result.diagnostics.join(' / '));
  for (const f of result.findings) {
    const mark = f.severity === 'error' ? '✗' : '△';
    lines.push(`${mark} ${result.file}:${f.line}:${f.column}  [${f.ruleId}] ${f.message}` + (f.excerpt ? `  «${f.excerpt}»` : ''));
  }
  if (!result.findings.length) lines.push('  (静的検出なし)');
  return lines.join('\n');
}

async function main() {
  const opts = parseArgs(process.argv);
  let content;
  if (opts.stdin || !opts.file) {
    if (process.stdin.isTTY && !opts.stdin) {
      console.error('使い方: node scripts/proofread.js <file> [--type prose|latex] [--format json|pretty]');
      process.exit(2);
    }
    content = fs.readFileSync(0, 'utf8');
  } else {
    content = fs.readFileSync(opts.file, 'utf8');
  }
  const result = await proofread(content, opts);
  if (opts.format === 'pretty') console.log(pretty(result));
  else console.log(JSON.stringify(result, null, 2));
}

if (require.main === module) {
  main().catch((e) => { console.error(e); process.exit(1); });
}

module.exports = { proofread };
