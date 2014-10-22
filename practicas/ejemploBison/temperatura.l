%{
#include <stdlib.h>
#include "temperatura.tab.h"
%}
entero "-"?[0-9]+
real "-"?[0-9]+"."[0-9]+
%%
C {return CENTIGRADOS;}
F {return FARENHEIT;}
{entero} {yylval.valInt = atoi(yytext); return HORA;}
{real} {yylval.valFloat = atof(yytext); return VALOR_TEMPERATURA;}
. ;
\n ;
%%
