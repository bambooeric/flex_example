%{
#include <stdlib.h>
#include "tiposDatos.h"
#include "consultasSql.tab.h"
%}
entero "-"?[0-9]+
string [a-zA-z]+
alfanumerico [a-zA-Z0-9]
strespacio [a-zA-Z0-9 ]+
correo {alfanumerico}+"@"{alfanumerico}+"."{alfanumerico}+
real "-"?[0-9]+"."[0-9]+
%%
idEmpleado {yylval.str = yytext;return IDEMPLEADO;}
nombre {yylval.str = yytext;return NOMBRE;}
puesto {yylval.str = yytext;return PUESTO;}
correo {yylval.str = yytext;return CAMPOCORREO;}
anho {yylval.str = yytext;return ANHO;}
salario {yylval.str = yytext;return SALARIO;}
(?i:SELECT) {return SELECT;}
(?i:FROM) {return FROM;}
(?i:WHERE) {return WHERE;}
\; {return PUNTOCOMA;}
\, {return COMA;}
\* {return ASTERISCO;}
\< {yylval.caracter =  '<';return MENOR;}
\>	{yylval.caracter =  '>';return MAYOR;}
\= {yylval.caracter =  '=';return IGUAL;}
\"{strespacio}\" {yylval.str = yytext; return STRESPACIO;}
{correo} {yylval.str = yytext; return CORREO;}
{string} {yylval.str = yytext; return STRING;}
{entero} {yylval.entero = atoi(yytext);return ENTERO;}
{real} {yylval.real = atof(yytext); return REAL;}

. {}

