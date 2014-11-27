%{
#include<stdlib.h>
#include "mips2c.tab.h"
%}
DIGIT [0-9]
ALPHA [A-Za-z]
WORD {ALPHA}*
%%

"#"[^\n]*				  {/*printf("COMENTARIO<%s>",yytext);*/}
^"#"[^\n]*"\n"			  {/*printf("COMENTARIO DE LINEA<%s>",yytext);*/}
"[ \t]+" 				  {/*printf("< >");*/}
^"\n"					  {/*printf("\\n\n");*/}

"\n"					  {/*printf("<eol>\n");*/return EOL;}
":"						  {/*printf("<:>");*/return PP;}
","						  {/*printf("<,>");*/return C;}
"("						  {/*printf("<(>");*/return P1;}
")"						  {/*printf("<)>");*/return P2;}

".globl"				  {/*printf("globl<%s>",yytext);*/return GLOBL;}
".text"					  {/*printf("text<%s>",yytext);*/return TEXT;}
".data"					  {/*printf("data<%s>",yytext);*/return DATA;}
"syscall" 				  {/*printf("<syscall>");*/return SYSCALL;}

{ALPHA}({ALPHA}|{DIGIT})* {/*printf("etiq<%s>",yytext);*/return ETIQ;}
"$"{ALPHA}?{DIGIT}*		  {/*printf("opr<%s>",yytext);*/return OPR;}
"."("float"|"int")		  {/*printf("tipo<%s>",yytext);*/return TIPO;}
-?{DIGIT}+("."{DIGIT}+)?  {/*printf("valor<%s>",yytext);*/return VALOR;}

%%
/*
main(){
    while(1) yylex();
}*/
