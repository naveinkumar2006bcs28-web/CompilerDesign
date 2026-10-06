%{
#include <stdio.h>
#include <math.h>

int yylex();
void yyerror(const char *s);
%}

%union {
    double num;
}

%token <num> NUMBER
%token PLUS MINUS MUL DIV MOD LPAREN RPAREN EOL

%type <num> expr

%left PLUS MINUS
%left MUL DIV MOD
%left UMINUS

%%
program:
    program stmt EOL
    |
    ;

stmt:
    expr { printf("Result: %.2f\n", $1); }
    ;

expr:
    NUMBER                { $$ = $1; }
    | expr PLUS expr      { $$ = $1 + $3; }
    | expr MINUS expr     { $$ = $1 - $3; }
    | expr MUL expr       { $$ = $1 * $3; }
    | expr DIV expr       {
                            if ($3 == 0) {
                                yyerror("Division by zero!");
                                $$ = 0;
                            } else {
                                $$ = $1 / $3;
                            }
                          }
    | expr MOD expr       {
                            if ((int)$3 == 0) {
                                yyerror("Modulo by zero!");
                                $$ = 0;
                            } else {
                                $$ = (int)$1 % (int)$3;
                            }
                          }
    | MINUS expr %prec UMINUS { $$ = -$2; }
    | LPAREN expr RPAREN  { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("Basic Calculator (+, -, *, /, %%)\n");
    printf("Enter expression and press Enter:\n");
    yyparse();
    return 0;
}
[
