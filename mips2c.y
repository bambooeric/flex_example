%error-verbose
%{
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

#define MAX_INSTRUCCIONES 100
#define MAX_DATA_SIZE 100
#define MAX_DATA_VARS 100

struct Instruccion{
	char* codigo;
	char* arg1;
	char* arg2;
	char* arg3;
};

struct DataVector{
	char* nombre;
	char* tipo;
	char* valor[MAX_DATA_SIZE];
	/* Debería inicializarse recorriendo la estructura, pero 
	 * los enteros creados en el programa principal como variable 
	 * global siempre son 0 si no se inicializan*/
	int nValores;
};

struct Instruccion instrucciones[MAX_INSTRUCCIONES];
struct DataVector vectores[MAX_DATA_VARS];

int nInstrucciones = 0;
int nVectores = 0;

void yyerror (char const * );

%}

%union{
	char* valString;
}
%token DATA TEXT GLOBL SYSCALL PP C EOL P1 P2
%token<valString> ETIQ OPR TIPO VALOR 
%type<valString> codigo text data definiciones definicion valores globl bloques bloque instrucciones instruccion operadores
%start S

%%

S : codigo 								{printf("CODIGO ACEPTADO!!!!!!!\n");}
;
codigo : text data 						{} 
	| data text							{}
	| data								{}
	| text								{}
;
data : DATA EOL definiciones 			{printf("-- seccion data\n");}
;
definiciones : definicion 				{printf("-- definicion detectada\n");} 
	| definicion definiciones 			{printf("-- queda mas definiciones\n");}
;
definicion : ETIQ PP TIPO valores EOL 	{printf("-- definicion\n");
		   									vectores[nVectores].nombre = strdup($1);
		   									vectores[nVectores].tipo = strdup($3);
											nVectores++;
		   								}
;
valores : VALOR 						{
											int nValores = vectores[nVectores].nValores;
											vectores[nVectores].valor[nValores] = strdup($1);
											vectores[nVectores].nValores++;
										}
	| VALOR C valores 					{
											int nValores = vectores[nVectores].nValores;
											vectores[nVectores].valor[nValores] = strdup($1);
											vectores[nVectores].nValores++;
										}
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
instruccion : ETIQ operadores EOL 		{printf("-- instruccion completa\n");
		   									instrucciones[nInstrucciones].codigo = strdup($1); 
											nInstrucciones++;
										}
	| SYSCALL EOL 						{printf("-- syscall invocado\n");
		   									instrucciones[nInstrucciones].codigo = strdup("SYSCALL"); 
											nInstrucciones++;
										}
;
operadores : OPR C OPR C OPR 			{printf("-- instruccion normal %s %s %s\n",$1,$3,$5);
		   									instrucciones[nInstrucciones].arg1 = strdup($1); 
		   									instrucciones[nInstrucciones].arg2 = strdup($3); 
		   									instrucciones[nInstrucciones].arg3 = strdup($5); 
										} 		   
	| OPR C OPR C VALOR 				{printf("-- instruccion i\n");
		   									instrucciones[nInstrucciones].arg1 = strdup($1); 
		   									instrucciones[nInstrucciones].arg2 = strdup($3); 
		   									instrucciones[nInstrucciones].arg3 = strdup($5);
										} 
	| OPR C VALOR P1 OPR P2				{printf("-- instruccion con desplazamiento\n");
		   									instrucciones[nInstrucciones].arg1 = strdup($1); 
		   									instrucciones[nInstrucciones].arg2 = strdup($3); 
		   									instrucciones[nInstrucciones].arg3 = strdup($5);
										} 
	| OPR C OPR C ETIQ	 				{printf("-- instruccion salto cond\n");
		   									instrucciones[nInstrucciones].arg1 = strdup($1); 
		   									instrucciones[nInstrucciones].arg2 = strdup($3); 
		   									instrucciones[nInstrucciones].arg3 = strdup($5);
										} 
	| ETIQ 								{printf("-- instruccion salto\n");
			   								instrucciones[nInstrucciones].arg1 = strdup($1); 
										} 
	| OPR C ETIQ						{printf("-- instruccion la\n");
		   									instrucciones[nInstrucciones].arg1 = strdup($1);
		   									instrucciones[nInstrucciones].arg2 = strdup($3);
										} 
;
%%
int main(int argc, char** argv){
	
	yyparse();

	int i;
	for(i=0;i<nInstrucciones;i++)
		printf("<%s>\n",instrucciones[i].codigo);
	
	for(i=0;i<nVectores;i++){
		printf("<%s>: ",vectores[i].nombre);
		int z;
		for(z=0;z<vectores[i].nValores;z++)
			printf("|%s|",vectores[i].valor[z]);
	}
}
void yyerror (char const *message) {
	fprintf(stderr, "%s\n",message);
}
