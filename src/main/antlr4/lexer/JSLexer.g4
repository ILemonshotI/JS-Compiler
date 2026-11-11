/*
 * JavaScript (ES2025) lexer - compilers project, part 1
 *
 * Damascus University, Faculty of Information Engineering, 4th year AI.
 *
 * Things to remember when editing this file:
 *  - ANTLR always takes the LONGEST match. If two rules match the same
 *    length, the one written FIRST wins. That's why keywords sit above
 *    IDENTIFIER and the error rules sit at the bottom of their section.
 *  - The Java helper code (brace counting, regex check, error reporting)
 *    lives in JSLexerBase.java so this file stays readable.
 */
lexer grammar JSLexer;

options {
    superClass = JSLexerBase;
}

// ERRORS is our own channel for "bad" tokens. They don't go to the parser,
// JSLexerBase turns them into error messages instead.
channels { ERRORS }

// this one is only ever set from code (see onCloseBrace in JSLexerBase)
tokens { TEMPLATE_EXPR_END }


// =====================================================================
//  COMMENTS
// =====================================================================
// kept on HIDDEN instead of skip, we still want to print them but the
// parser won't see them later

MULTI_LINE_COMMENT  : '/*' .*? '*/'                -> channel(HIDDEN) ;
SINGLE_LINE_COMMENT : '//' ~[\r\n\u2028\u2029]*    -> channel(HIDDEN) ;

// "/*" that never gets closed. can't contain "*/" anywhere, otherwise
// it would eat the real comment + the rest of the file
UNTERMINATED_COMMENT : '/*' ( ~'*' | '*'+ ~[*/] )* '*'* EOF -> channel(ERRORS) ;


// =====================================================================
//  REGEX LITERALS   e.g.  /ab+c/gi
// =====================================================================
// "/" can mean divide or start a regex. regexAllowed() looks at the token
// before it: after a value (x, 5, ")", "]" ...) it's a divide, otherwise a regex.
// it has to be above the operators so "/=abc/" can still be a regex.

REGEX_LITERAL
    : '/' RegexFirstChar RegexChar* { regexAllowed() }? '/' IdPart*
    ;

fragment RegexFirstChar : ~[*/\\[\r\n\u2028\u2029] | RegexBackslash | RegexClass ;
fragment RegexChar      : ~[/\\[\r\n\u2028\u2029]  | RegexBackslash | RegexClass ;
fragment RegexBackslash : '\\' ~[\r\n\u2028\u2029] ;
// inside [...] a "/" doesn't end the regex:  /[/]/
fragment RegexClass     : '[' ( ~[\]\\\r\n\u2028\u2029] | RegexBackslash )* ']' ;


// =====================================================================
//  PUNCTUATION / OPERATORS
// =====================================================================

OPEN_BRACE    : '{' { onOpenBrace(); } ;
CLOSE_BRACE   : '}' { onCloseBrace(); } ;   // might turn into TEMPLATE_EXPR_END
OPEN_PAREN    : '(' ;
CLOSE_PAREN   : ')' ;
OPEN_BRACKET  : '[' ;
CLOSE_BRACKET : ']' ;
SEMICOLON     : ';' ;
COMMA         : ',' ;
ELLIPSIS      : '...' ;
DOT           : '.' ;
COLON         : ':' ;
// a?.5:1 is "?" then ".5", not optional chaining. JS spec says so
OPTIONAL_CHAIN : '?.' { !Character.isDigit(_input.LA(1)) }? ;
QUESTION       : '?' ;
ARROW          : '=>' ;

// arithmetic
PLUS        : '+' ;
MINUS       : '-' ;
STAR        : '*' ;
SLASH       : '/' ;
PERCENT     : '%' ;
POWER       : '**' ;
PLUS_PLUS   : '++' ;
MINUS_MINUS : '--' ;

// comparison
LESS          : '<' ;
GREATER       : '>' ;
LESS_EQ       : '<=' ;
GREATER_EQ    : '>=' ;
EQUALS        : '==' ;
NOT_EQUALS    : '!=' ;
STRICT_EQ     : '===' ;
STRICT_NOT_EQ : '!==' ;

// bitwise
LEFT_SHIFT     : '<<' ;
RIGHT_SHIFT    : '>>' ;
U_RIGHT_SHIFT  : '>>>' ;
BIT_AND        : '&' ;
BIT_OR         : '|' ;
BIT_XOR        : '^' ;
BIT_NOT        : '~' ;

// logical
NOT      : '!' ;
AND      : '&&' ;
OR       : '||' ;
NULLISH  : '??' ;

// assignment
ASSIGN               : '=' ;
PLUS_ASSIGN          : '+=' ;
MINUS_ASSIGN         : '-=' ;
STAR_ASSIGN          : '*=' ;
SLASH_ASSIGN         : '/=' ;
PERCENT_ASSIGN       : '%=' ;
POWER_ASSIGN         : '**=' ;
LEFT_SHIFT_ASSIGN    : '<<=' ;
RIGHT_SHIFT_ASSIGN   : '>>=' ;
U_RIGHT_SHIFT_ASSIGN : '>>>=' ;
BIT_AND_ASSIGN       : '&=' ;
BIT_OR_ASSIGN        : '|=' ;
BIT_XOR_ASSIGN       : '^=' ;
AND_ASSIGN           : '&&=' ;
OR_ASSIGN            : '||=' ;
NULLISH_ASSIGN       : '??=' ;


// =====================================================================
//  LITERALS: null / boolean
// =====================================================================

NULL_LITERAL : 'null' ;
BOOLEAN      : 'true' | 'false' ;


// =====================================================================
//  KEYWORDS
// =====================================================================
// must stay above IDENTIFIER (same length match -> first rule wins).
// "variable" is still an IDENTIFIER though, longest match beats VAR.
// words like of/get/set/from/as are NOT here on purpose, in JS they're
// only special in some places so the parser will deal with them.

// variable declarations (the "Variable" group in the assignment)
VAR   : 'var' ;
LET   : 'let' ;
CONST : 'const' ;

BREAK      : 'break' ;
CASE       : 'case' ;
CATCH      : 'catch' ;
CLASS      : 'class' ;
CONTINUE   : 'continue' ;
DEBUGGER   : 'debugger' ;
DEFAULT    : 'default' ;
DELETE     : 'delete' ;
DO         : 'do' ;
ELSE       : 'else' ;
ENUM       : 'enum' ;
EXPORT     : 'export' ;
EXTENDS    : 'extends' ;
FINALLY    : 'finally' ;
FOR        : 'for' ;
FUNCTION   : 'function' ;
IF         : 'if' ;
IMPORT     : 'import' ;
IN         : 'in' ;
INSTANCEOF : 'instanceof' ;
NEW        : 'new' ;
RETURN     : 'return' ;
SUPER      : 'super' ;
SWITCH     : 'switch' ;
THIS       : 'this' ;
THROW      : 'throw' ;
TRY        : 'try' ;
TYPEOF     : 'typeof' ;
VOID       : 'void' ;
WHILE      : 'while' ;
WITH       : 'with' ;
YIELD      : 'yield' ;
ASYNC      : 'async' ;
AWAIT      : 'await' ;
STATIC     : 'static' ;

// reserved in strict mode, nobody uses them but they're in the spec
IMPLEMENTS : 'implements' ;
INTERFACE  : 'interface' ;
PACKAGE    : 'package' ;
PRIVATE    : 'private' ;
PROTECTED  : 'protected' ;
PUBLIC     : 'public' ;


// =====================================================================
//  NUMBERS
// =====================================================================
// "_" is allowed only BETWEEN two digits: 1_000 ok, 1__0 / _1 / 1_ not ok.
// bigint goes first so 123n isn't read as 123 then n

BIGINT
    : ( DecimalInt | '0' [xX] HexDigits | '0' [oO] OctalDigits | '0' [bB] BinaryDigits ) 'n'
    ;

HEX_NUMBER    : '0' [xX] HexDigits ;
// second alt is the old style octal (017 == 15), only valid in non-strict code
OCTAL_NUMBER  : '0' [oO] OctalDigits | '0' [0-7]+ ;
BINARY_NUMBER : '0' [bB] BinaryDigits ;

FLOAT
    : DecimalInt '.' Digits? Exponent?    // 3.14   5.   1.e3
    | '.' Digits Exponent?                // .5
    | DecimalInt Exponent                 // 1e3
    ;

// "08" / "09" are old JS weirdness, still decimal
INTEGER : DecimalInt | '0' [0-9]* [89] [0-9]* ;

// anything that starts like a number but runs into letters/underscores:
// 1__0, 1_, 0x, 0b102, 1.5n, 3abc, 1e+ ...
// it only wins when it's LONGER than a valid number (tie -> valid rule wins
// since that one is written first)
INVALID_NUMBER
    : ( [0-9] | '.' [0-9] ) [0-9a-zA-Z_$]* ( '.' [0-9a-zA-Z_$]* )?   -> channel(ERRORS)
    ;

fragment DecimalInt   : '0' | [1-9] ( '_'? [0-9] )* ;
fragment Digits       : [0-9] ( '_'? [0-9] )* ;
fragment Exponent     : [eE] [+-]? Digits ;
fragment HexDigits    : HexDigit ( '_'? HexDigit )* ;
fragment OctalDigits  : [0-7] ( '_'? [0-7] )* ;
fragment BinaryDigits : [01] ( '_'? [01] )* ;
fragment HexDigit     : [0-9a-fA-F] ;


// =====================================================================
//  STRINGS  '...'  "..."
// =====================================================================
// - the other quote inside is just a normal char:   "it's"   'say "hi"'
// - a real line break is NOT allowed inside
// - BUT backslash + line break = line continuation, string keeps going
//   on the next line and it's still ONE token

STRING
    : '"'  DoubleStringChar* '"'
    | '\'' SingleStringChar* '\''
    ;

fragment DoubleStringChar : ~["\\\r\n] | EscapeSequence ;
fragment SingleStringChar : ~['\\\r\n] | EscapeSequence ;

fragment EscapeSequence
    : '\\' ( '\r\n'                          // line continuation (windows line ending)
           | 'x' HexDigit HexDigit           // \x41
           | 'u' HexDigit HexDigit HexDigit HexDigit   // A
           | 'u{' HexDigit+ '}'              // \u{1F600}
           | ~[xu]                           // \n \t \' \" \\ \0, and \ + newline
           )
    ;

// closed string with a broken escape like "\x4G" or "\u12".
// same length as a good STRING -> STRING wins, so this only fires on bad ones
INVALID_ESCAPE_STRING
    : ( '"'  ( ~["\\\r\n] | '\\' ( '\r\n' | . ) )* '"'
      | '\'' ( ~['\\\r\n] | '\\' ( '\r\n' | . ) )* '\''
      ) -> channel(ERRORS)
    ;

// no closing quote before the end of the line -> the error from the assignment
// ( var s = "abc  )
UNTERMINATED_STRING
    : ( '"'  ( ~["\\\r\n] | '\\' ( '\r\n' | . ) )*
      | '\'' ( ~['\\\r\n] | '\\' ( '\r\n' | . ) )*
      ) -> channel(ERRORS)
    ;


// =====================================================================
//  TEMPLATE LITERALS  `...${expr}...`
// =====================================================================
// the backtick switches to TEMPLATE mode (see the bottom of the file).
// "${" jumps back to the normal mode so the expression gets lexed like
// normal code, and the matching "}" brings us back (onCloseBrace).
// since modes are a stack, nesting works for free:  `a ${ `b ${c}` } d`

TEMPLATE_START : '`' { onTemplateStart(); } -> pushMode(TEMPLATE) ;


// =====================================================================
//  IDENTIFIERS
// =====================================================================
// letters from any language are fine (ID_Start / ID_Continue), plus $ and _
// #name is a private class field

IDENTIFIER         : IdStart IdPart* ;
PRIVATE_IDENTIFIER : '#' IdStart IdPart* ;

fragment IdStart       : [\p{ID_Start}$_] | UnicodeEscape ;
fragment IdPart        : [\p{ID_Continue}$\u200C\u200D] | UnicodeEscape ;
fragment UnicodeEscape : '\\u' HexDigit HexDigit HexDigit HexDigit | '\\u{' HexDigit+ '}' ;


// =====================================================================
//  WHITESPACE
// =====================================================================

WHITESPACE      : [\t\u000B\u000C\u0020\u00A0\uFEFF\p{Zs}]+ -> skip ;
LINE_TERMINATOR : [\r\n\u2028\u2029]+                       -> skip ;

// last rule in default mode: if nothing above matched, it's an error (@, \ ...)
ERROR_CHAR : . -> channel(ERRORS) ;


// =====================================================================
mode TEMPLATE;
// =====================================================================

TEMPLATE_END        : '`'  { onTemplateEnd(); }        -> popMode ;
TEMPLATE_EXPR_START : '${' { onTemplateExprStart(); }  -> pushMode(DEFAULT_MODE) ;

// the text parts. anything goes (newlines too) except:
//  `   ends the template
//  ${  starts an expression. a "$" on its own is fine ( `price: $5` )
//  \   escapes the next char, so \` and \${ are just text
TEMPLATE_STRING
    : ( ~[`\\$] | '\\' . | '$' { _input.LA(1) != '{' }? )+
    ;
