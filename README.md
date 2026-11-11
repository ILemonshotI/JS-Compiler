# JS Compiler, part 1: lexical analyzer

ANTLR4 lexer for JavaScript (ES2025), written in Java and built with Maven.
The full explanation for the team (how it works, who does what) is in the shared doc.
This file is only the quick version.

## Open it

IntelliJ: **File > Open**, pick the `JsCompiler` folder (or `pom.xml`), and choose **Open as Project**.
IntelliJ downloads ANTLR and JUnit by itself the first time, which needs internet.

**First time only:** after the import finishes, open the Maven panel (the "m" on the right edge) and click
**Reload All Maven Projects** (the circular arrows). If you skip this, IntelliJ says `cannot find symbol JSLexer`,
because the generated lexer folder didn't exist yet when the project was first scanned.

## Run it

The run configurations are already in the dropdown at the top right:

| Configuration | What it does |
|---|---|
| `Lexer: all special cases` | lexes `tests/all_special_cases.js` |
| `Lexer: errors` | lexes the files that contain mistakes, so you can see the error list |
| `Lexer: my_test.js` | lexes `my_test.js`, a scratch file for your own experiments |
| `All tests (mvn test)` | checks every `tests/*.js` against `tests/expected/*.txt` |

From a terminal (only if you have Maven installed):

```
mvn test
mvn compile exec:java -Dexec.args="tests/errors.js"
```

## Layout

```
src/main/antlr4/lexer/JSLexer.g4     the grammar (token rules)
src/main/java/lexer/JSLexerBase.java helper code the grammar calls (templates, regex, errors)
src/main/java/lexer/LexerRunner.java prints tokens + errors in the required format
src/main/java/lexer/Main.java        entry point
src/test/java/lexer/...              automated test
tests/*.js                           test inputs
tests/expected/*.txt                 the output we checked by hand
```

## After changing the grammar

1. Run `All tests (mvn test)`.
2. A red test means the output changed. Read the diff and decide whether that was the change you wanted.
3. If it was, regenerate the expected file with `Main --save tests/that_file.js`. Check it again before you commit.
