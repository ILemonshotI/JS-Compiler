package lexer;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Runs the lexer over some input and builds the output in the format the
 * assignment wants:
 *
 *   --- Tokens Found ---
 *   Text: [var] -> Type: VAR (1:1)
 *   ...
 *   --- Lexical Errors: N ---
 *   Error at 3:9 message
 *
 * Kept separate from Main so the tests can call it directly.
 */
public class LexerRunner {

    // ANTLR counts columns from 0, editors (IntelliJ, VS Code) count from 1.
    // we print 1-based so you can jump straight to the spot in the editor.
    private static final int COLUMN_OFFSET = 1;

    public static String run(CharStream input) {
        JSLexer lexer = new JSLexer(input);

        List<LexError> errors = new ArrayList<>();
        lexer.removeErrorListeners();   // default one just prints to stderr
        lexer.addErrorListener(new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                                    int line, int column, String msg, RecognitionException e) {
                errors.add(new LexError(line, column + COLUMN_OFFSET, msg));
            }
        });

        StringBuilder out = new StringBuilder();
        out.append("--- Tokens Found ---\n");

        for (Token t : lexer.getAllTokens()) {
            if (t.getChannel() == JSLexer.ERRORS) continue;   // already reported as an error

            out.append("Text: [").append(printable(t.getText())).append("]")
               .append(" -> Type: ").append(JSLexer.VOCABULARY.getSymbolicName(t.getType()))
               .append(" (").append(t.getLine()).append(":")
               .append(t.getCharPositionInLine() + COLUMN_OFFSET).append(")\n");
        }

        // the template error is found at EOF, so sort to keep everything in file order
        errors.sort(Comparator.comparingInt((LexError e) -> e.line).thenComparingInt(e -> e.column));

        out.append("--- Lexical Errors: ").append(errors.size()).append(" ---\n");
        for (LexError e : errors) {
            out.append("Error at ").append(e.line).append(":").append(e.column)
               .append(" ").append(e.message).append("\n");
        }
        return out.toString();
    }

    /** Multi-line tokens (comments, templates, continued strings) would break the
     *  one-token-per-line output, so show line breaks and tabs as \n \r \t. */
    private static String printable(String text) {
        return text.replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t");
    }

    private static class LexError {
        final int line;
        final int column;
        final String message;

        LexError(int line, int column, String message) {
            this.line = line;
            this.column = column;
            this.message = message;
        }
    }
}
