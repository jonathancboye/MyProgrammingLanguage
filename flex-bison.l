%{
#include <cstdlib>
#include <iostream>
#include <string>
#include <cstring>
using namespace std;
#define YY_DECL extern "C" int yylex()
#include "flex-bison.tab.h"
int double_quotes = 0;
%}

%x DQUOTE
			
%%
[ \t\n]
if {return IF;}
while {return WHILE;}
else {return ELSE;}
new {return NEW;}
print {return PRINT;}
randchar {return RANDCHAR;}
[0-9]+ {yylval.num = atoi(yytext); return NUM;}
$i_[a-zA-z0-9]+ {yylval.str = strdup(yytext); return IV;}
$s_[a-zA-z0-9]+ {yylval.str = strdup(yytext); return STRV;}
$o_[a-zA-z0-9]+ {yylval.str = strdup(yytext); return OBJ;}

<DQUOTE>[:,\- |_$a-zA-z0-9]+ {
    BEGIN(INITIAL);
    yylval.str = strdup(yytext);
    return STR;
 }

[.] {return DOT;}
[,] {return COMMA;}
[+] {return ADD;}
[-] {return SUB;}
[<] {return LT;}
[*] {return MUL;}
[/] {return DIV;}
[;] {return SEMI;}
[?] {return QUESTION;}
[:] {return COLON;}
[(] {return LP;}
[)] {return RP;}
[{] {return LB;}
[}] {return RB;}
[=] {return ASSIGN;}

["] {
    if(double_quotes) {
        double_quotes = 0;
    } else {
	BEGIN(DQUOTE);
        double_quotes = 1;
    }
    return QUOTE;
 }
%%
