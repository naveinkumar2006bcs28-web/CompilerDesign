%{
#include<stdio.h>
#include<string.h>
#include<ctype.h>
%}
%%
.* {
    int len = strlen(yytext);

    /* Remove newline if present */
    if(yytext[len-1]=='\n')
    {
        yytext[len-1]='\0';
        len--;
    }

    int upper=0, lower=0, digit=0, special=0;
    int i;

    /* Check first character */
    if(!isalpha(yytext[0]))
    {
        printf("Invalid Password: Password must start with an alphabet.\n");
        return 0;
    }
    if(len < 8)
    {
        printf("Invalid Password: Length should be at least 8.\n");
        return 0;
    }

    if(len > 64)
    {
        printf("Invalid Password: Length should not exceed 64.\n");
        return 0;
    }
    for(i=0;i<len;i++)
    {
        if(isupper(yytext[i]))
            upper=1;
        else if(islower(yytext[i]))
            lower=1;
        else if(isdigit(yytext[i]))
            digit=1;
        else if(yytext[i]=='&' || yytext[i]=='@' || yytext[i]=='$' || yytext[i]=='-')
            special=1;
        else
        {
            printf("Invalid Password: Invalid character '%c'.\n", yytext[i]);
            return 0;
        }
    }

    if(!upper)
        printf("Invalid: No uppercase letter.\n");

    if(!lower)
        printf("Invalid: No lowercase letter.\n");

    if(!digit)
        printf("Invalid: No digit.\n");

    if(!special)
        printf("Invalid: No special character.\n");

    if(upper && lower && digit && special)
        printf("Valid Password.\n");
}

%%

int yywrap()
{
    return 1;
}

int main()
{
    printf("Enter Password: ");
    yylex();
    return 0;
}
