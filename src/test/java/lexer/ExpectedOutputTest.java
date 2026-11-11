package lexer;

import org.antlr.v4.runtime.CharStreams;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * For every tests/X.js there should be a tests/expected/X.txt with the output
 * we checked by hand. This runs the lexer on each .js and compares.
 *
 * Added a new test file? run:  Main --save tests/yourfile.js
 * then open tests/expected/yourfile.txt and actually READ it before committing,
 * otherwise we're just testing that the lexer agrees with itself.
 */
class ExpectedOutputTest {

    private static final Path TESTS = Paths.get("tests");
    private static final Path EXPECTED = TESTS.resolve("expected");

    @TestFactory
    Stream<DynamicTest> everyTestFileMatchesItsExpectedOutput() throws IOException {
        List<Path> jsFiles;
        try (Stream<Path> files = Files.list(TESTS)) {
            jsFiles = files.filter(p -> p.toString().endsWith(".js")).sorted().collect(Collectors.toList());
        }
        assertTrue(!jsFiles.isEmpty(), "no .js files found in " + TESTS.toAbsolutePath());

        return jsFiles.stream().map(js -> DynamicTest.dynamicTest(js.getFileName().toString(), () -> {
            String name = js.getFileName().toString().replaceAll("\\.js$", "") + ".txt";
            Path expectedFile = EXPECTED.resolve(name);
            assertTrue(Files.exists(expectedFile),
                    "missing " + expectedFile + "  (generate it with: Main --save " + js + ")");

            String expected = Files.readString(expectedFile, StandardCharsets.UTF_8);
            String actual = LexerRunner.run(CharStreams.fromPath(js, StandardCharsets.UTF_8));

            // git on windows may turn \n into \r\n in the checked-out files, ignore that
            assertEquals(normalize(expected), normalize(actual), "output changed for " + js);
        }));
    }

    private static String normalize(String s) {
        return s.replace("\r\n", "\n").replace("\\r", "").trim();
    }
}
