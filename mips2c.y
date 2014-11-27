%error-verbose
%{
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

#define MAX_INSTRUCCIONES 100
#define MAX_DATA_SIZE 100
#define MAX_DATA_VARS 100
#define MAX_BLOQUES 10

struct Args{
	char* args[3];
};

struct Instruccion{
	char* codigo;
	char* args[3];
};

struct Bloque{
	char* etiqueta;
	struct Instruccion *instrucciones[MAX_INSTRUCCIONES]; //ordenadas según se van apareciendo en el bloque
	int nInstrucciones;
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

struct Instruccion* INST[MAX_INSTRUCCIONES];
struct Bloque *bloques[MAX_BLOQUES];
struct DataVector vectores[MAX_DATA_VARS];

int nBloques = 0;

int nInstrucciones = 0;
int nVectores = 0;

void yyerror (char const * );

%}

%union{
	char* valString;
	struct Instruccion* valInstruccion;
	struct Args* valArgs;
	struct Bloque* valBloque;
}
%token DATA TEXT GLOBL SYSCALL PP C EOL P1 P2
%token<valString> ETIQ OPR TIPO VALOR
%type<valString> codigo text data definiciones definicion valores globl bloques instrucciones 
%type<valInstruccion> instruccion
%type<valArgs> operadores
%type<valBloque> bloque
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
bloque : ETIQ PP EOL instrucciones  	{printf("-- bloque de instrucciones\n");
	   										struct Bloque* bloque = (struct Bloque*) malloc(sizeof(struct Bloque*));
											bloque->etiqueta = strdup($1);
											int i;
											for(i=0;i<nInstrucciones;i++)
												bloque->instrucciones[i] = INST[i];

											bloque->nInstrucciones = nInstrucciones;
											nInstrucciones = 0; // para la siguiente?

											bloques[nBloques] = bloque;
											nBloques++;
	   									}
;
instrucciones : instruccion				{printf("-- instruccion detectada\n");
			  								INST[nInstrucciones] = $1;
											nInstrucciones++;
			  							} 
	| instruccion instrucciones 		{printf("-- quedan mas instrucciones\n");
											INST[nInstrucciones] = $1;
											nInstrucciones++;
										}
;
instruccion : ETIQ operadores EOL 		{printf("-- instruccion completa\n");
											struct Instruccion* instruccion = (struct Instruccion*) malloc(sizeof(struct Instruccion*));
											instruccion->codigo = strdup($1);

											if($2->args[0]!=NULL) instruccion->args[0] = strdup($2->args[0]);
											if($2->args[1]!=NULL) instruccion->args[1] = strdup($2->args[1]);
											if($2->args[2]!=NULL) instruccion->args[2] = strdup($2->args[2]);

											$$ = instruccion;
										}
	| SYSCALL EOL 						{printf("-- syscall invocado\n");
											struct Instruccion* instruccion = (struct Instruccion*) malloc(sizeof(struct Instruccion*));
											instruccion->codigo = strdup("SYSCALL");

											instruccion->args[0] = NULL;
											instruccion->args[1] = NULL;
											instruccion->args[2] = NULL;

											$$ = instruccion;
										}
;
operadores : OPR C OPR C OPR 			{printf("-- instruccion normal ");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args*));
											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);
											$$ = args;
										} 		   
	| OPR C OPR C VALOR 				{printf("-- instruccion i\n");
											struct Args* args = (struct Args*) malloc(sizeof(struct Args*));
											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);
											$$ = args;

										} 
	| OPR C VALOR P1 OPR P2				{printf("-- instruccion con desplazamiento\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args*));
											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);
											$$ = args;

										} 
	| OPR C OPR C ETIQ	 				{printf("-- instruccion salto cond\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args*));
											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);
											$$ = args;

										} 
	| ETIQ 								{printf("-- instruccion salto\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args*));
											args->args[0] = strdup($1);
											args->args[1] = NULL;
											args->args[2] = NULL;
											$$ = args;

										} 
	| OPR C ETIQ						{printf("-- instruccion la\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args*));
											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = NULL;
											$$ = args;

										} 
;
%%
int main(int argc, char** argv){
	
	yyparse();
/*
	int i;
	for(i=0;i<nInstrucciones;i++)
		printf("<%s>\n",instrucciones[i].codigo);
	
	for(i=0;i<nVectores;i++){
		printf("<%s>: ",vectores[i].nombre);
		int z;
		for(z=0;z<vectores[i].nValores;z++)
			printf("|%s|",vectores[i].valor[z]);
	}
*/
printf("%d\n",bloques[0]->nInstrucciones);
int x;
for(x=0;x<bloques[0]->nInstrucciones;x++)
	printf("%s\n",bloques[0]->instrucciones[x]->codigo);
}
void yyerror (char const *message) {
	fprintf(stderr, "%s\n",message);
}
