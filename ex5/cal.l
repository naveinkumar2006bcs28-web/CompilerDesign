%{
#include "y.tab.h"
#include <stdlib.h>
%}

%%
[0-9]+         { yylval.num = atoi(yytext); return NUMBER; }
[0-9]+\.[0-9]+ { yylval.num = atof(yytext); return NUMBER; }

"+"            { return PLUS; }
"-"            { return MINUS; }
"*"            { return MUL; }
"/"            { return DIV; }
"%"            { return MOD; }
"("            { return LPAREN; }
")"            { return RPAREN; }

[ \t]          ;
\n             { return EOL; }
.              { printf("Unknown character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}
