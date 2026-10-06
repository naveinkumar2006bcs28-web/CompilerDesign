%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;

int valid_for = 0;
%}

%union {
    char *str;
}

%token <str> TOK_FOR TOK_IN TOK_PRINT TOK_RANGE TOK_IF TOK_ELSE TOK_PASS TOK_KEYWORD
%token <str> TOK_BOOL
%token <str> TOK_LOGICAL
%token <str> TOK_PRE_INCR TOK_PRE_DECR TOK_POST_INCR TOK_POST_DECR
%token <str> TOK_IDENT
%token <str> TOK_UNARY_NUM
%token <str> TOK_NUMBER
%token <str> TOK_RELATIONAL
%token <str> TOK_COMPOUND
%token <str> TOK_ASSIGN
%token <str> TOK_ARITH
%token <str> TOK_STRING
%token <str> TOK_COLON TOK_LPAREN TOK_RPAREN TOK_COMMA TOK_LBRACKET TOK_RBRACKET
%token <str> TOK_UNKNOWN

%left TOK_LOGICAL
%left TOK_RELATIONAL
%left TOK_ARITH
%right TOK_UNARY
%left TOK_POST_INCR TOK_POST_DECR

%%

program:
    stmt_list
    ;

stmt_list:
    /* empty */
    | stmt_list stmt
    ;

stmt:
    expr
    | TOK_IDENT TOK_ASSIGN expr
    | TOK_IDENT TOK_COMPOUND expr
    | for_stmt
    | if_stmt
    | print_stmt
    | pass_stmt
    ;

for_stmt:
    TOK_FOR TOK_IDENT TOK_IN expr TOK_COLON stmt_list
    { valid_for = 1; }
    | TOK_FOR TOK_IDENT TOK_IN expr TOK_COLON stmt_list TOK_ELSE TOK_COLON stmt_list
    { valid_for = 1; }
    ;

if_stmt:
    TOK_IF expr TOK_COLON stmt_list
    | TOK_IF expr TOK_COLON stmt_list TOK_ELSE TOK_COLON stmt_list
    ;

print_stmt:
    TOK_PRINT TOK_LPAREN expr TOK_RPAREN
    ;

pass_stmt:
    TOK_PASS
    ;

expr:
    TOK_IDENT
    | TOK_NUMBER
    | TOK_UNARY_NUM
    | TOK_BOOL
    | TOK_STRING
    | TOK_LBRACKET opt_expr_list TOK_RBRACKET
    | TOK_RANGE TOK_LPAREN opt_expr_list TOK_RPAREN
    | expr TOK_ARITH expr
    | expr TOK_RELATIONAL expr
    | expr TOK_LOGICAL expr
    | TOK_LOGICAL expr %prec TOK_UNARY
    | TOK_PRE_INCR expr %prec TOK_UNARY
    | TOK_PRE_DECR expr %prec TOK_UNARY
    | expr TOK_POST_INCR
    | expr TOK_POST_DECR
    | TOK_LPAREN expr TOK_RPAREN
    | TOK_UNKNOWN
    ;

opt_expr_list:
    /* empty */
    | expr_list
    ;

expr_list:
    expr
    | expr_list TOK_COMMA expr
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "[PARSE ERROR] %s\n", s);
}

int main(int argc, char *argv[])
{
    yyin = fopen("input1.txt", "r");
    if (!yyin)
    {
        fprintf(stderr, "[FATAL] Could not open input file: input1.txt\n");
        return 1;
    }

    if (yyparse() == 0)
    {
        if (valid_for)
            printf("[PASS] Valid for loop detected.\n");
        else
            printf("[INFO] Not a valid for loop.\n");
    }
    else
    {
        printf("[FAIL] Invalid syntax encountered.\n");
    }

    fclose(yyin);
    return 0;
}
