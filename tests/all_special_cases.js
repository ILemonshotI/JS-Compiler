// ---- 1. Strings on ONE line -----------------------------------------
var s1 = 'single quotes';
var s2 = "double quotes";
var s3 = 'It\'s escaped';          // \' inside '...'  -> one STRING
var s4 = "say \"hi\"";             // \" inside "..."  -> one STRING
var s5 = 'say "hi"';               // other quote inside is plain text
var s6 = "it's fine";              // ' inside "..." is plain text
var s7 = "back\\slash";            // \\ then slash, string continues
var s8 = 'tab\there\nnewline';     // \t \n are escapes, NOT a real newline
var s9 = "\x41 A \u{1F600}";  // \xHH, \uHHHH, \u{...}
var s10 = '';                      // empty string
var s11 = "";                      // empty string
var s12 = "http://example.com";    // // inside a string is NOT a comment
var s13 = '/* not a comment */';   // /* */ inside a string is NOT a comment
var s14 = "${not_a_template}";     // ${ inside "..." is plain text
var s15 = "back`tick";             // backtick inside "..." is plain text
var s16 = '\0';                    // \0 is a valid escape

// ---- 2. Strings on SEVERAL lines (line continuation) ----------------
// A backslash right before the line break continues the string.
// This is ONE STRING token that spans two lines.
var m1 = "first line \
second line";
var m2 = 'a\
b\
c';                                // ONE STRING token over three lines

// ---- 3. Template literals -------------------------------------------
var name = 10;
var a = 4;
var b = 4;
var c = 4;
var d = 4;
var t1 = `plain template`;
var t2 = ``;                                   // empty template
var t3 = `line one
line two
line three`;                                   // real newlines are allowed
var t4 = `hello ${name}!`;                     // one ${ ... }
var t5 = `${a}${b}${c}`;                       // adjacent expressions
var t6 = `sum: ${1 + 2}, str: ${'x' + "y"}`;   // expressions with strings
var t7 = `price: $5, brace: {}`;               // $ alone, {} alone: plain text
var t8 = `escaped \` backtick and \${ not an expr }`;
var t9 = `a ${ `b ${ `c ${d}` }` } e`;         // templates nested 3 levels

var t13 = `back\\slash and \n escape`;         // escapes are kept as written

// ---- 4. Comments ----------------------------------------------------
// line comment up to the end of the line
var c1 = 1; // trailing comment
/* block comment on one line */
/* block comment
   over several
   lines */
/** doc comment **/
/**/
/***/
/* // inside block */
// /* inside line comment
var c2 = 2; /* inline */ var c3 = 3;
var c4 = "a" /* between tokens */ + "b";

// ---- 5. Numbers -----------------------------------------------------
var n1 = 42;            // INTEGER
var n2 = 1_000_000;     // separator allowed between digits
var n3 = 3.14;          // FLOAT
var n4 = .5;            // FLOAT starting with a dot
var n5 = 5.;            // FLOAT ending with a dot
var n6 = 1e3;           // exponent
var n7 = 2.5E-3;        // signed exponent
var n8 = 0xFF;          // HEX_NUMBER
var n9 = 0o17;          // OCTAL_NUMBER
var n10 = 0b1010;       // BINARY_NUMBER
var n11 = 123n;         // BIGINT
var n12 = 0xFFn;        // BIGINT (hex)
var n13 = 1_0.0_1;      // separators in both parts
var n14 = 0;            // zero
