package lexer;

import org.antlr.v4.runtime.CharStreams;

import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Usage:
 *   Main                        -> lexes tests/all_special_cases.js
 *   Main file1.js file2.js      -> lexes the given files
 *   Main --save file.js         -> also writes the output to tests/expected/file.txt
 *                                  (use this after adding a new test file, then
 *                                   CHECK the .txt by hand before committing it)
 */
public class Main {

    private static final String DEFAULT_FILE = "tests/all_special_cases.js";

    public static void main(String[] args) throws IOException {
        // windows console likes to mangle non-ascii chars otherwise
        PrintStream console = new PrintStream(System.out, true, StandardCharsets.UTF_8);

        boolean save = false;
        java.util.List<String> files = new java.util.ArrayList<>();
        for (String arg : args) {
            if (arg.equals("--save")) save = true;
            else files.add(arg);
        }
        if (files.isEmpty()) files.add(DEFAULT_FILE);

        for (String file : files) {
            Path path = Paths.get(file);
            if (!Files.exists(path)) {
                console.println("File not found: " + path.toAbsolutePath());
                continue;
            }

            String result = LexerRunner.run(CharStreams.fromPath(path, StandardCharsets.UTF_8));

            if (files.size() > 1) console.println("===== " + file + " =====");
            console.print(result);

            if (save) {
                String name = path.getFileName().toString().replaceAll("\\.js$", "") + ".txt";
                Path target = Paths.get("tests", "expected", name);
                Files.createDirectories(target.getParent());
                Files.writeString(target, result, StandardCharsets.UTF_8);
                console.println("(saved to " + target + ")");
            }
        }
    }
}
