%error-verbose
%{
#include<stdlib.h>
#include<stdio.h>
#include<string.h>


void yyerror (char const * );

%}

%union{
	char* valString;
}
%token DATA TEXT GLOBL PP C EOL P1 P2
%token<valString> ETIQ OPR TIPO VALOR 
%type<valString> codigo text data definiciones definicion valores globl bloques bloque instrucciones instruccion operadores
%start S

%%

S : codigo 								{printf("CODIGO ACEPTADO!!!!!!!\n");}
;
codigo : text data 						{printf("HOLA!\n");} 
	| data text							{printf("HOLA!\n");}
	| data								{printf("HOLA!\n");}
	| text								{printf("HOLA!\n");}
;
data : DATA EOL definiciones 			{printf("-- seccion data\n");}
;
definiciones : definicion 				{printf("-- definicion detectada\n");} 
	| definicion definiciones 			{printf("-- queda mas definiciones\n");}
;
definicion : ETIQ PP TIPO valores EOL 	{printf("-- definicion\n");}
;
valores : VALOR 						{}
	| VALOR C valores 					{}
;
text : TEXT EOL globl    				{printf("-- seccion text\n");}
;
globl : GLOBL ETIQ EOL bloques 			{printf("-- bloque inicial\n");}
;
bloques : bloque 						{printf("-- bloque detectado\n");} 
	| bloque bloques  					{printf("-- quedan mas bloques\n");}
;
bloque : ETIQ PP EOL instrucciones  	{printf("-- bloque de instrucciones\n");}
;
instrucciones : instruccion				{printf("-- instruccion detectada\n");} 
	| instruccion instrucciones 		{printf("-- quedan mas instrucciones\n");}
;
instruccion : ETIQ operadores EOL 		{printf("-- instruccion completa\n");}
;
operadores : OPR C OPR C OPR 			{printf("-- instruccion normal\n");} 
	| OPR C OPR C VALOR 				{printf("-- instruccion i\n");} 
	| OPR C VALOR '(' OPR ')'			{printf("-- instruccion con desplazamiento\n");} 
	| OPR C OPR C ETIQ	 				{printf("-- instruccion salto cond\n");} 
	| ETIQ 								{printf("-- instruccion salto\n");} 
;
%%
int main(int argc, char** argv){
	yyparse();
}
void yyerror (char const *message) {
	fprintf(stderr, "%s\n",message);
}
