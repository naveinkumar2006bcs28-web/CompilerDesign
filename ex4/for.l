%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

/* Print a formatted token trace to stderr */
static void emit_token(const char* tok_name, const char* lexeme) {
    fprintf(stderr, "[TOKEN: %-18s | LEXEME: %s]\n", tok_name, lexeme);
}

%}

%s PRE_STATE POST_STATE

%%

 /* Keywords & Language Constructs */
<INITIAL>"for"              { emit_token("TOK_FOR", yytext); yylval.str = strdup(yytext); return TOK_FOR; }
<INITIAL>"in"               { emit_token("TOK_IN", yytext); yylval.str = strdup(yytext); return TOK_IN; }
<INITIAL>"print"            { emit_token("TOK_PRINT", yytext); yylval.str = strdup(yytext); return TOK_PRINT; }
<INITIAL>"range"            { emit_token("TOK_RANGE", yytext); yylval.str = strdup(yytext); return TOK_RANGE; }
<INITIAL>"break"|"continue" { emit_token("TOK_KEYWORD", yytext); yylval.str = strdup(yytext); return TOK_KEYWORD; }
<INITIAL>"pass"             { emit_token("TOK_PASS", yytext); yylval.str = strdup(yytext); return TOK_PASS; }
<INITIAL>"if"               { emit_token("TOK_IF", yytext); yylval.str = strdup(yytext); return TOK_IF; }
<INITIAL>"else"             { emit_token("TOK_ELSE", yytext); yylval.str = strdup(yytext); return TOK_ELSE; }
<INITIAL>"True"|"False"     { emit_token("TOK_BOOL", yytext); yylval.str = strdup(yytext); return TOK_BOOL; }

 /* Logical Operators */
<INITIAL>"and"|"or"|"not"|"&&"|"||" {
    emit_token("TOK_LOGICAL", yytext);
    yylval.str = strdup(yytext);
    return TOK_LOGICAL;
}

 /* Pre-increment / Pre-decrement (switch to PRE_STATE) */
<INITIAL>"++"               { emit_token("TOK_PRE_INCR", yytext); yylval.str = strdup(yytext); BEGIN PRE_STATE; return TOK_PRE_INCR; }
<INITIAL>"--"               { emit_token("TOK_PRE_DECR", yytext); yylval.str = strdup(yytext); BEGIN PRE_STATE; return TOK_PRE_DECR; }

 /* PRE_STATE: capture the identifier after ++/-- */
<PRE_STATE>[ \t\n]+         { /* skip whitespace */ }
<PRE_STATE>[a-zA-Z_][a-zA-Z0-9_]* {
    emit_token("TOK_IDENT", yytext);
    yylval.str = strdup(yytext);
    BEGIN POST_STATE;
    return TOK_IDENT;
}
<PRE_STATE>.|\n             { yyless(0); BEGIN 0; }

 /* INITIAL identifiers */
<INITIAL>[a-zA-Z_][a-zA-Z0-9_]* {
    emit_token("TOK_IDENT", yytext);
    yylval.str = strdup(yytext);
    BEGIN POST_STATE;
    return TOK_IDENT;
}

 /* POST_STATE: check for postfix ++/-- */
<POST_STATE>[ \t\n]+        { /* skip whitespace */ }
<POST_STATE>"++"            { emit_token("TOK_POST_INCR", yytext); yylval.str = strdup(yytext); BEGIN 0; return TOK_POST_INCR; }
<POST_STATE>"--"            { emit_token("TOK_POST_DECR", yytext); yylval.str = strdup(yytext); BEGIN 0; return TOK_POST_DECR; }
<POST_STATE>.|\n            { yyless(0); BEGIN 0; }

 /* Numeric literals */
<INITIAL>[+-][0-9]+(\.[0-9]+)? {
    emit_token("TOK_UNARY_NUM", yytext);
    yylval.str = strdup(yytext);
    return TOK_UNARY_NUM;
}
<INITIAL>[0-9]+(\.[0-9]+)? {
    emit_token("TOK_NUMBER", yytext);
    yylval.str = strdup(yytext);
    return TOK_NUMBER;
}

 /* Relational & Compound Assignment Operators */
<INITIAL>"=="|"!="|"<="|">="|"<"|">" {
    emit_token("TOK_RELATIONAL", yytext);
    yylval.str = strdup(yytext);
    return TOK_RELATIONAL;
}
<INITIAL>"+="|"-="|"*="|"/=" {
    emit_token("TOK_COMPOUND", yytext);
    yylval.str = strdup(yytext);
    return TOK_COMPOUND;
}

 /* Simple Assignment & Arithmetic */
<INITIAL>"="                { emit_token("TOK_ASSIGN", yytext); yylval.str = strdup(yytext); return TOK_ASSIGN; }
<INITIAL>[-+*/]             { emit_token("TOK_ARITH", yytext); yylval.str = strdup(yytext); return TOK_ARITH; }

 /* String literals */
<INITIAL>\"([^\\\"]|\\.)*\" {
    emit_token("TOK_STRING", yytext);
    yylval.str = strdup(yytext);
    return TOK_STRING;
}

 /* Punctuation & Separators */
<INITIAL>":"                { emit_token("TOK_COLON", yytext); yylval.str = strdup(yytext); return TOK_COLON; }
<INITIAL>"("                { emit_token("TOK_LPAREN", yytext); yylval.str = strdup(yytext); return TOK_LPAREN; }
<INITIAL>")"                { emit_token("TOK_RPAREN", yytext); yylval.str = strdup(yytext); return TOK_RPAREN; }
<INITIAL>","                { emit_token("TOK_COMMA", yytext); yylval.str = strdup(yytext); return TOK_COMMA; }
<INITIAL>"["                { emit_token("TOK_LBRACKET", yytext); yylval.str = strdup(yytext); return TOK_LBRACKET; }
<INITIAL>"]"                { emit_token("TOK_RBRACKET", yytext); yylval.str = strdup(yytext); return TOK_RBRACKET; }

 /* Whitespace & Unknown */
<INITIAL>[ \t\n]+           { /* skip whitespace */ }
<INITIAL>.                  { emit_token("TOK_UNKNOWN", yytext); yylval.str = strdup(yytext); return TOK_UNKNOWN; }

%%

int yywrap(void) {
    return 1;
}
