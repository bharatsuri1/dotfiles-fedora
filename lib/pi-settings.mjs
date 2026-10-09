// Merge portable Pi preferences into a local file, preserving runtime keys.
import fs from "node:fs";
import path from "node:path";

const [mode, source, target, backupRoot] = process.argv.slice(2);
if (!["deploy", "check"].includes(mode) || !source || !target) {
  throw new Error("usage: pi-settings.mjs deploy|check source target [backup-root]");
}
const readObject = (file) => {
  const value = JSON.parse(fs.readFileSync(file, "utf8"));
  if (!value || Array.isArray(value) || typeof value !== "object") {
    throw new Error(`${file} must contain a JSON object`);
  }
  return value;
};
const isObject = (value) => value && typeof value === "object" && !Array.isArray(value);
const merge = (existing, managed) => {
  const result = { ...existing };
  for (const [key, value] of Object.entries(managed)) {
    Object.defineProperty(result, key, {
      value: isObject(value) ? merge(isObject(existing[key]) ? existing[key] : {}, value) : value,
      enumerable: true, configurable: true, writable: true,
    });
  }
  return result;
};
const managed = readObject(source);
// This is runtime state even if an older template accidentally contains it.
delete managed.lastChangelogVersion;
const stat = fs.lstatSync(target, { throwIfNoEntry: false });
const existing = stat ? readObject(target) : {};
const merged = merge(existing, managed);
const matches = JSON.stringify(merged) === JSON.stringify(existing);
if (mode === "check") {
  process.exit(stat && !stat.isSymbolicLink() && matches ? 0 : 1);
}
if (!backupRoot) throw new Error("deploy requires a backup directory");
if (stat && !stat.isSymbolicLink() && matches) process.exit(0);
if (stat) {
  fs.mkdirSync(backupRoot, { recursive: true });
  const backup = fs.mkdtempSync(path.join(backupRoot, "pi-settings-"));
  fs.copyFileSync(target, path.join(backup, "settings.json"));
  fs.chmodSync(path.join(backup, "settings.json"), 0o600);
  console.log(`Pi settings backup: ${backup}/settings.json`);
}
fs.mkdirSync(path.dirname(target), { recursive: true });
const stage = fs.mkdtempSync(path.join(path.dirname(target), ".pi-settings-"));
try {
  const stagedFile = path.join(stage, "settings.json");
  fs.writeFileSync(stagedFile, `${JSON.stringify(merged, null, 2)}\n`, { mode: 0o600 });
  // Atomic replacement also detaches a legacy symlink without writing its source.
  fs.renameSync(stagedFile, target);
} finally {
  fs.rmSync(stage, { recursive: true, force: true });
}
