// Fix code with the project's own ESLint: code in on stdin, fixed code out on stdout. No temp file.
//   node eslint-fix.mjs <file path>      (run from the project folder)
import { createRequire } from "node:module";
import { pathToFileURL } from "node:url";

const file = process.argv[2];
const cwd = process.cwd();
let code = "";
for await (const chunk of process.stdin) code += chunk;

// pnpm keeps eslint in node_modules/.pnpm, so look there too
let eslintPath;
try {
  eslintPath = createRequire(cwd + "/package.json").resolve("eslint", {
    paths: [cwd, cwd + "/node_modules/.pnpm/node_modules"],
  });
} catch {
  process.stdout.write(code);
  process.exit(0);
}

const { ESLint } = await import(pathToFileURL(eslintPath).href);
const [result] = await new ESLint({ cwd, fix: true }).lintText(code, { filePath: file });
process.stdout.write(result?.output ?? code);
