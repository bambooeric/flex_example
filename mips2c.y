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
%token<valString> ETIQ OP OPR DESPL TIPO VALOR 
%type<valString> codigo text data definiciones definicion valores globl bloques bloque instrucciones instruccion operadores
%start S

%%

S : codigo 								{printf("HOLA!\n");}
;
codigo : text data 						{printf("HOLA!\n");} 
	| data text							{printf("HOLA!\n");}
	| data								{printf("HOLA!\n");}
	| text								{printf("HOLA!\n");}
;
data : DATA EOL definiciones 			{printf("HOLA!\n");}
;
definiciones : definicion 				{printf("HOLA!\n");} 
	| definicion definiciones 			{printf("HOLA!\n");}
;
definicion : ETIQ PP TIPO valores EOL 	{printf("HOLA!\n");}
;
valores : VALOR 						{printf("HOLA!\n");}
	| VALOR C valores 					{printf("HOLA!\n");}
;
text : TEXT EOL globl    				{printf("HOLA!\n");}
;
globl : GLOBL ETIQ EOL bloques 			{printf("HOLA!\n");}
;
bloques : bloque 						{printf("HOLA!\n");} 
	| bloque bloques  					{printf("HOLA!\n");}
;
bloque : ETIQ PP EOL instrucciones  	{printf("HOLA!\n");}
;
instrucciones : instruccion				{printf("HOLA!\n");} 
	| instruccion instrucciones 		{printf("HOLA!\n");}
;
instruccion : OP operadores EOL 		{printf("HOLA!\n");}
;
operadores : OPR C OPR C OPR 			{printf("HOLA!\n");} 
	| OPR C OPR C VALOR 				{printf("HOLA!\n");} 
	| OPR C DESPL '(' OPR ')'			{printf("HOLA!\n");} 
	| OPR C OPR C ETIQ	 				{printf("HOLA!\n");} 
	| ETIQ 								{printf("HOLA!\n");} 
;
%%
int main(int argc, char** argv){
	yyparse();
}
void yyerror (char const *message) {
	fprintf(stderr, "%s\n",message);
}
