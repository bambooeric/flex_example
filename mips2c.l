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
[ \t]+ 				  	  {/*printf("< >");*/}

\n					      {/*printf("<eol>\n");*/return EOL;}
":"						  {/*printf("<:>");*/return PP;}
","						  {/*printf("<,>");*/return C;}
"("						  {/*printf("<(>");*/return P1;}
")"						  {/*printf("<)>");*/return P2;}

".globl"				  {/*printf("globl<%s>",yytext);*/return GLOBL;}
".text"					  {/*printf("text<%s>",yytext);*/return TEXT;}
".data"					  {/*printf("data<%s>",yytext);*/return DATA;}
"syscall" 				  {/*printf("<syscall>");*/return SYSCALL;}

{ALPHA}({ALPHA}|{DIGIT})* {/*printf("etiq<%s>",yytext);*/yylval.valString = strdup(yytext);return ETIQ;}
{ALPHA}({ALPHA}|{DIGIT})*":" {
								yylval.valString = strdup(yytext);
								yylval.valString[strlen(yylval.valString)-1] = 0;
								return ETIQPP;
							}
"$"{ALPHA}?{DIGIT}*		  {/*printf("opr<%s>",yytext);*/yylval.valString = strdup(yytext);return OPR;}
"."("float"|"int")		  {
								char* _s = strdup(yytext);
								_s++;
								yylval.valString = strdup(_s);
								free(--_s);
								return TIPO;
							}
-?{DIGIT}+("."{DIGIT}+)?  {/*printf("valor<%s>",yytext);*/yylval.valString = strdup(yytext);return VALOR;}

%%
/*
main(){
    while(1) yylex();
}*/
