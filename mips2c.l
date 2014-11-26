%{
#include<stdlib.h>
#include "mips2c.tab.h"
%}
DIGIT [0-9]
ALPHA [A-Za-z]
WORD {ALPHA}*
%%

"#".*$					  {printf("COMENTARIO<%s>",yytext);}
"\n"					  {printf("eol<%s>",yytext);return EOL;}
":"						  {return PP;}
","						  {return C;}
"("						  {return P1;}
")"						  {return P2;}

".globl"				  {printf("globl<%s>",yytext);return DATA;}
".text"					  {printf("text<%s>",yytext);return TEXT;}
".data"					  {printf("data<%s>",yytext);return GLOBL;}

{ALPHA}({ALPHA}|{DIGIT})*  {printf("etiq<%s>",yytext);return ETIQ;}
"$"{ALPHA}?{DIGIT}*		  {printf("opr<%s>",yytext);return OPR;}
{DIGIT}+				  {printf("despl<%s>",yytext);return DESPL;}
"."("float"|"int")		  {printf("tipo<%s>",yytext);return TIPO;}
-?{DIGIT}+("."{DIGIT}+)?  {printf("valor<%s>",yytext);return VALOR;}
.						  {printf("wat<%s>",yytext);}

%%
/*
main(){
    while(1) yylex();
}*/
