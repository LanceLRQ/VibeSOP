#!/usr/bin/env node
// Structure checks for every skill under skills/. No dependencies.
// Usage: node tests/check.mjs
import { execFileSync } from 'node:child_process';
import { readdirSync, readFileSync, existsSync, statSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const skillsDir = join(root, 'skills');
const failures = [];
let checks = 0;

function check(ok, message) {
  checks += 1;
  if (!ok) failures.push(message);
}

function listFiles(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? listFiles(path) : [path];
  });
}

const read = (path) => readFileSync(path, 'utf8');
const rel = (path) => relative(root, path);
const hanLines = (text) =>
  text.split('\n').flatMap((line, i) => (/\p{Script=Han}/u.test(line) ? [i + 1] : []));
const placeholders = (text) => [...new Set(text.match(/\{\{[A-Z_]+\}\}/g) ?? [])].sort().join(' ');
const markers = (text) => (text.match(/(>>>|<<<) [A-Z_]+/g) ?? []).join(' ');
const headings = (text) => (text.match(/^#{1,6} /gm) ?? []).map((h) => h.trim().length).join(' ');

function checkFrontmatter(skill, text) {
  const match = text.match(/^---\n([\s\S]*?)\n---\n/);
  check(Boolean(match), `${skill}: SKILL.md has no frontmatter`);
  if (!match) return '';
  const name = match[1].match(/^name: (.*)$/m)?.[1] ?? '';
  const description = match[1].match(/^description: (.*)$/m)?.[1] ?? '';
  check(name === skill, `${skill}: frontmatter name "${name}" differs from the directory name`);
  check(/^[a-z0-9-]+$/.test(name), `${skill}: name may contain only lowercase letters, digits and hyphens`);
  check(description.startsWith('Use when'), `${skill}: description must start with "Use when"`);
  check(match[1].length <= 1024, `${skill}: frontmatter is ${match[1].length} characters, limit is 1024`);
  return text.slice(match[0].length);
}

function checkEnglishOnly(path, text) {
  const lines = hanLines(text);
  check(lines.length === 0, `${rel(path)}: CJK characters on line ${lines.slice(0, 5).join(', ')}`);
}

function checkTemplatesAligned(skill, templatesDir) {
  const names = (lang) => readdirSync(join(templatesDir, lang)).sort();
  const en = names('en');
  const zh = names('zh');
  check(en.join(' ') === zh.join(' '), `${skill}: templates/en and templates/zh hold different files`);
  for (const name of en.filter((n) => zh.includes(n))) {
    const a = read(join(templatesDir, 'en', name));
    const b = read(join(templatesDir, 'zh', name));
    check(placeholders(a) === placeholders(b), `${skill}: templates/*/${name} differ in placeholders`);
    check(markers(a) === markers(b), `${skill}: templates/*/${name} differ in block markers`);
    check(headings(a) === headings(b), `${skill}: templates/*/${name} differ in heading levels`);
    checkEnglishOnly(join(templatesDir, 'en', name), a);
  }
}

function checkSkill(skill) {
  const dir = join(skillsDir, skill);
  const skillFile = join(dir, 'SKILL.md');
  check(existsSync(skillFile), `${skill}: SKILL.md is missing`);
  if (!existsSync(skillFile)) return;
  const text = read(skillFile);
  const body = checkFrontmatter(skill, text);
  checkEnglishOnly(skillFile, body);

  const references = listFiles(join(dir, 'references'));
  for (const path of references) {
    const name = `references/${relative(join(dir, 'references'), path)}`;
    check(text.includes(name), `${skill}: ${name} is never mentioned in SKILL.md`);
    if (!path.endsWith('glossary.md')) checkEnglishOnly(path, read(path));
  }
  for (const name of new Set(text.match(/references\/[a-z0-9-]+\.md/g) ?? [])) {
    check(existsSync(join(dir, name)), `${skill}: SKILL.md mentions ${name}, which does not exist`);
  }

  const docs = [skillFile, ...references];
  for (const path of docs) {
    const escaped = read(path).split('\n').flatMap((line, i) => (/`[^`]*\\\|[^`]*`/.test(line) ? [i + 1] : []));
    check(escaped.length === 0, `${rel(path)}: escaped pipe inside a command on line ${escaped.join(', ')}`);
  }

  // Only skills that number their decisions (D1…) and checks (V1…) get this cross-check.
  const decisionIds = new Set(text.match(/\b[DV]\d+\b/g) ?? []);
  for (const path of decisionIds.size > 0 ? references : []) {
    const unknown = [...new Set(read(path).match(/\b[DV]\d+\b/g) ?? [])].filter((id) => !decisionIds.has(id));
    check(unknown.length === 0, `${rel(path)}: refers to ${unknown.join(', ')}, not defined in SKILL.md`);
  }

  const templatesDir = join(dir, 'templates');
  if (existsSync(join(templatesDir, 'en')) && existsSync(join(templatesDir, 'zh'))) {
    checkTemplatesAligned(skill, templatesDir);
    for (const name of readdirSync(join(templatesDir, 'en'))) {
      check(text.includes(`\`${name}\``), `${skill}: template ${name} is never mentioned in SKILL.md`);
    }
    const named = [...text.matchAll(/`([A-Za-z.-]+\.template|gitignore-[a-z]+\.txt)`/g)].map((m) => m[1]);
    for (const name of new Set(named)) {
      check(existsSync(join(templatesDir, 'en', name)), `${skill}: SKILL.md names template ${name}, which does not exist`);
    }
  }
}

// A file under skills/ that an ignore rule catches would be missing from the published skill.
function checkNothingIgnored() {
  let ignored;
  try {
    ignored = execFileSync('git', ['ls-files', '--others', '--ignored', '--exclude-standard', '--', 'skills'], {
      cwd: root,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
  } catch {
    return; // not a git checkout
  }
  check(ignored === '', `ignored by git, so never published: ${ignored.split('\n').join(', ')}`);
}

const skills = readdirSync(skillsDir).filter((name) => statSync(join(skillsDir, name)).isDirectory());
check(skills.length > 0, 'no skills found under skills/');
skills.forEach(checkSkill);
checkNothingIgnored();

if (failures.length > 0) {
  console.error(failures.map((f) => `FAIL ${f}`).join('\n'));
  console.error(`\n${failures.length} of ${checks} checks failed`);
  process.exit(1);
}
console.log(`ok: ${checks} checks across ${skills.length} skill(s)`);
