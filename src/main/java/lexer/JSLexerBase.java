package lexer;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Token;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * Java side of the lexer. JSLexer (generated from JSLexer.g4) extends this,
 * so the grammar can call these methods from its actions / predicates.
 *
 * Three jobs:
 *   1. count braces inside ${ ... } so we know which "}" closes it
 *   2. decide if "/" is a regex or a divide
 *   3. turn tokens on the ERRORS channel into error messages
 */
public abstract class JSLexerBase extends Lexer {

    // one counter per open "${". the number = how many normal "{" are open
    // inside that expression right now. stack because templates can nest.
    private final Deque<Integer> templateBraces = new ArrayDeque<>();

    // where each open backtick started, for the "unterminated template" error
    private final Deque<int[]> templateStarts = new ArrayDeque<>();

    // last token that actually means something (no comments / errors)
    private Token lastToken = null;

    private boolean reportedEofErrors = false;

    protected JSLexerBase(CharStream input) {
        super(input);
    }

    // ------------------------------------------------------------------
    // braces + templates
    // ------------------------------------------------------------------

    protected void onTemplateStart() {
        // careful: getLine()/getCharPositionInLine() here would give the position
        // AFTER the backtick (the action runs once it's matched), so use the token start
        templateStarts.push(new int[] { _tokenStartLine, _tokenStartCharPositionInLine });
    }

    protected void onTemplateEnd() {
        if (!templateStarts.isEmpty()) templateStarts.pop();
    }

    protected void onTemplateExprStart() {
        templateBraces.push(0);
    }

    protected void onOpenBrace() {
        // only matters when we're inside a ${ }, otherwise nothing to track
        if (!templateBraces.isEmpty()) {
            templateBraces.push(templateBraces.pop() + 1);
        }
    }

    protected void onCloseBrace() {
        if (templateBraces.isEmpty()) return;   // normal block / object brace

        int open = templateBraces.pop();
        if (open == 0) {
            // this "}" closes the ${ -> go back to reading template text
            setType(JSLexer.TEMPLATE_EXPR_END);
            popMode();
        } else {
            templateBraces.push(open - 1);      // closes something like ${ {a:1} }
        }
    }

    // ------------------------------------------------------------------
    // regex vs divide
    // ------------------------------------------------------------------

    /**
     * After something that is a value, "/" means divide:  a / b,  (x) / 2,  arr[0] / 3
     * Anywhere else it starts a regex:  x = /ab+c/,  return /x/,  ( /x/ )
     * Same trick the grammars-v4 JavaScript lexer uses. Not perfect (a "}" can
     * end a block or an object) but good enough for real code.
     */
    protected boolean regexAllowed() {
        if (lastToken == null) return true;

        switch (lastToken.getType()) {
            case JSLexer.IDENTIFIER:
            case JSLexer.PRIVATE_IDENTIFIER:
            case JSLexer.NULL_LITERAL:
            case JSLexer.BOOLEAN:
            case JSLexer.THIS:
            case JSLexer.SUPER:
            case JSLexer.INTEGER:
            case JSLexer.FLOAT:
            case JSLexer.HEX_NUMBER:
            case JSLexer.OCTAL_NUMBER:
            case JSLexer.BINARY_NUMBER:
            case JSLexer.BIGINT:
            case JSLexer.STRING:
            case JSLexer.TEMPLATE_END:
            case JSLexer.REGEX_LITERAL:
            case JSLexer.CLOSE_PAREN:
            case JSLexer.CLOSE_BRACKET:
            case JSLexer.CLOSE_BRACE:
            case JSLexer.PLUS_PLUS:
            case JSLexer.MINUS_MINUS:
                return false;
            default:
                return true;
        }
    }

    // ------------------------------------------------------------------
    // errors
    // ------------------------------------------------------------------

    @Override
    public Token nextToken() {
        Token t = super.nextToken();

        if (t.getChannel() == JSLexer.ERRORS) {
            report(t.getLine(), t.getCharPositionInLine(), messageFor(t));
        } else if (t.getChannel() == Token.DEFAULT_CHANNEL && t.getType() != Token.EOF) {
            lastToken = t;
        }

        if (t.getType() == Token.EOF && !reportedEofErrors) {
            reportedEofErrors = true;
            // still inside a template when the file ended. report it where the
            // outermost unclosed backtick was, that's where the mistake is
            if (!templateStarts.isEmpty()) {
                int[] pos = templateStarts.peekLast();
                report(pos[0], pos[1], "Unterminated template literal");
            }
        }
        return t;
    }

    private String messageFor(Token t) {
        String text = t.getText();
        switch (t.getType()) {
            case JSLexer.UNTERMINATED_STRING:
                return "Invalid or unexpected token (unterminated string literal)";
            case JSLexer.INVALID_ESCAPE_STRING:
                return "Invalid escape sequence in string literal";
            case JSLexer.UNTERMINATED_COMMENT:
                return "Unterminated multi-line comment";
            case JSLexer.INVALID_NUMBER:
                return "Invalid or unexpected token (malformed number '" + text + "')";
            default:
                return "Invalid or unexpected token '" + text + "'";
        }
    }

    private void report(int line, int column, String message) {
        // goes to whatever error listener Main/LexerRunner attached
        getErrorListenerDispatch().syntaxError(this, null, line, column, message, null);
    }

    @Override
    public void reset() {
        super.reset();
        templateBraces.clear();
        templateStarts.clear();
        lastToken = null;
        reportedEofErrors = false;
    }
}
