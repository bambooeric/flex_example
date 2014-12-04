
%error-verbose
%{
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#define foreach( idxtype , idxpvar , col , colsiz ) idxtype* idxpvar; for( idxpvar=col ; idxpvar < (col+(colsiz)) ; idxpvar++)

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

char* bloqueInicial;

int nInstrucciones = 0;
int nVectores = 0;
int instruccionVacia = 0;
void yyerror (char const * );

%}

%union{
	char* valString;
	struct Instruccion* valInstruccion;
	struct Args* valArgs;
}
%token DATA TEXT GLOBL SYSCALL PP C EOL P1 P2 
%token<valString> ETIQ OPR TIPO VALOR ETIQPP
%type<valString> codigo text data definiciones definicion valores globl bloques instrucciones 
%type<valInstruccion> instruccion
%type<valArgs> operadores
%start S

%%

S : codigo 								{/*printf("CODIGO ACEPTADO!!!!!!!\n");*/}
;
codigo : text data 						{} 
	| data text							{}
	| data								{}
	| text								{}
;
data : DATA EOL definiciones 			{/*printf("-- seccion data\n");*/}
;
definiciones : definicion 				{/*printf("-- definicion detectada\n");*/} 
	| definicion definiciones 			{/*printf("-- queda mas definiciones\n");*/}
;
definicion : ETIQPP TIPO valores EOL 	{//printf("-- definicion\n");
		   									vectores[nVectores].nombre = strdup($1);
		   									vectores[nVectores].tipo = strdup($2);
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
text : TEXT EOL globl    				{/*printf("-- seccion text\n");*/}
;
globl : GLOBL ETIQ EOL bloques 			{/*printf("-- bloque inicial\n");*/
	  										bloqueInicial = strdup($2);
										}
;
bloques : ETIQPP EOL instrucciones EOL  {//printf("-- bloque de instrucciones\n");
	   										struct Bloque* bloque = (struct Bloque*) malloc(sizeof(struct Bloque));
											bloque->etiqueta = strdup($1);

											int i;
											for(i=0;i<nInstrucciones;i++)
												bloque->instrucciones[i] = INST[i];

											bloque->nInstrucciones = nInstrucciones;
											nInstrucciones = 0; // para la siguiente?

											bloques[nBloques] = bloque;
											nBloques++;
	   									}
	| bloques ETIQPP EOL instrucciones EOL {//printf("-- bloque de instrucciones\n");
	   										struct Bloque* bloque = (struct Bloque*) malloc(sizeof(struct Bloque));
											bloque->etiqueta = strdup($2);

											int i;
											for(i=0;i<nInstrucciones;i++)
												bloque->instrucciones[i] = INST[i];

											bloque->nInstrucciones = nInstrucciones;
											nInstrucciones = 0; // para la siguiente?

											bloques[nBloques] = bloque;
											nBloques++;
}
;
instrucciones : instruccion				{//printf("-- instruccion detectada\n");
											if(!instruccionVacia){
												INST[nInstrucciones] = $1;
												nInstrucciones++;
											}
											instruccionVacia = 0;

			  							} 
	| instrucciones instruccion 		{//printf("-- quedan mas instrucciones\n");
											if(!instruccionVacia){
												INST[nInstrucciones] = $2;
												nInstrucciones++;
											}
											instruccionVacia = 0;
										}
;
instruccion : ETIQ operadores EOL 		{//printf("-- instruccion completa\n");
											struct Instruccion* instruccion = (struct Instruccion*) malloc(sizeof(struct Instruccion));
											instruccion->codigo = strdup($1);

											if($2->args[0]!=NULL) instruccion->args[0] = strdup($2->args[0]);
											if($2->args[1]!=NULL) instruccion->args[1] = strdup($2->args[1]);
											if($2->args[2]!=NULL) instruccion->args[2] = strdup($2->args[2]);

											$$ = instruccion;
										}
	| SYSCALL EOL 						{//printf("-- syscall invocado\n");
											struct Instruccion* instruccion = (struct Instruccion*) malloc(sizeof(struct Instruccion));
											instruccion->codigo = strdup("SYSCALL");

											instruccion->args[0] = NULL;
											instruccion->args[1] = NULL;
											instruccion->args[2] = NULL;

											$$ = instruccion;
										}
	| EOL 								{instruccionVacia=1;}
;
operadores : OPR C OPR C OPR 			{//printf("-- instruccion normal ");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);

											$$ = args;
										} 		   
	| OPR C OPR C VALOR 				{//printf("-- instruccion i\n");
											struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);

											$$ = args;
										} 
	| OPR C VALOR P1 OPR P2				{//printf("-- instruccion con desplazamiento\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);

											$$ = args;
										} 
	| OPR C OPR C ETIQ	 				{//printf("-- instruccion salto cond\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = strdup($5);

											$$ = args;
										} 
	| ETIQ 								{//printf("-- instruccion salto\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = strdup($1);
											args->args[1] = NULL;
											args->args[2] = NULL;

											$$ = args;
										} 
	| OPR C ETIQ						{//printf("-- instruccion la\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = strdup($1);
											args->args[1] = strdup($3);
											args->args[2] = NULL;

											$$ = args;
										} 
;
%%

void printASMCode(){
	printf("Initial sec: <%s>\n",bloqueInicial);
    int i,j,k;
    for (i=0;i<nBloques;i++) {
        printf("%s",bloques[i]->etiqueta);
        printf(" (%d)\n",bloques[i]->nInstrucciones);
        for (j=0;j<bloques[i]->nInstrucciones;j++) {
            printf("\t%s ",bloques[i]->instrucciones[j]->codigo);
            k = 0;
            while (k < 3 && bloques[i]->instrucciones[j]->args[k] != NULL) {
                printf("%s ", bloques[i]->instrucciones[j]->args[k++]);
            }
            printf("\n");
        }
    }
	printf("DATA SECTION\n");
	for (i=0; i<nVectores; i++){
		printf("\t%s: ",vectores[i].nombre);
		printf("%s -> ",vectores[i].tipo);
		for(j=vectores[i].nValores - 1; j>=0; j--){
			printf("%s ", vectores[i].valor[j]);
		}
		printf("\n");
	}
}

char* cHeaders(){
	char* buf = (char*) malloc(sizeof(char)*255);
	snprintf(buf, 255, "#include <stdlib.h>\n#include <stdio.h>\n");
	return buf;
}
char* asmDataToC(){
	int i,j;
	char buf[2048];
	strcpy(buf,"// zona de datos\n");

	for(i=0;i<nVectores;i++){
		strcat(buf, vectores[i].tipo);
		strcat(buf, " ");
		strcat(buf, vectores[i].nombre);
		strcat(buf, "[] = {");
		for(j=vectores[i].nValores - 1; j>=0; j--){
			strcat(buf, vectores[i].valor[j]);
			if(j>0) strcat(buf,", ");
		}
		strcat(buf, "};\n");
	}

	return strdup(buf);
}

char* cFuncHeaders(){
	char buf[2048];
	int i;
	strcpy(buf,"// cabeceras de funciones que representan bloques de código MIPS\n");
    for (i=0;i<nBloques;i++) {
        strcat(buf,"void _");
        strcat(buf,bloques[i]->etiqueta);
        strcat(buf,"();\n");
	}

	return strdup(buf);
}

int isRegister(char* inst){
	char _i = inst[0];

	if((strlen(inst)==3) && (_i == '$'))
		return 1;
	else 
		return 0;
}

char** arrAppend(char** arr, char* e, int arrlen){
	char** arr2 = malloc((arrlen + 1) * sizeof(char*)); //lenth of the older array + 1 char* items
	memcpy(arr2,arr,arrlen * sizeof(char*));            //copy older array
	arr2[arrlen] = strdup(e);                           //copy new array in the last
	free(arr);                                          //and cleanup

	return arr2;
} 

int declaredArg(char** declared,int dec_len, char* inst){
	foreach(char*, arg, declared,dec_len){
		if((strcmp(*arg,inst)==0)){
			return 1;
		}
	}
	return 0;

}


char* registerDeclarations(){
	// get all registers referenced in the asm instructions
	char** declared = 0;
	int dec_len = 0;
	int i,j,k;
    for (i=0;i<nBloques;i++) {
        for (j=0;j<bloques[i]->nInstrucciones;j++) {
            k = 0;
            while (k < 3 && bloques[i]->instrucciones[j]->args[k] != NULL) {
				char* inst = strdup(bloques[i]->instrucciones[j]->args[k++]);
				if (isRegister(inst)){
					if (!declaredArg(declared, dec_len, inst)){
						declared = arrAppend(declared,inst,dec_len);
						dec_len++;
					}
				}
            }
        }
    }

	// print declarations into string
	char buf[2048];

	strcpy(buf,"// Declaraciones de registros referenciados en el código MIPS\n");
	strcat(buf,"int ");
	i=0;
	foreach(char*, inst, declared, dec_len){
        strcat(buf, ++*inst);
		i++;
		if(i<dec_len) strcat(buf,", ");
	}
	strcat(buf,";\n");

	return strdup(buf);
}

char* cMain(){
	char buf[2048];

	strcpy(buf,"// Llamada al bloque inicial\n");
	strcat(buf,"int main(){\n\t_");
	strcat(buf,bloqueInicial);
	strcat(buf,"();\n\treturn 0;\n}");

	return strdup(buf);
}
char* instructionToC(struct Instruccion* inst){
	char buf[255];

	strcpy(buf,"\t");
	if(strcmp(inst->codigo, "la")==0){
		strcat(buf,"instruccion la");
	}
	strcat(buf,";\n");

	printf("\t%s ",inst->codigo);
	int k = 0;
	while (k < 3 && inst->args[k] != NULL) {
		printf("%s ", inst->args[k++]);
	}

	return strdup(buf);
}

char* blocksToFuctions(){
	char buf[1024*1024];
	strcpy(buf, "// Funciones que representan cada bloque de código MIPS\n");

    int i,j,k;
    for (i=0;i<nBloques;i++) {
		// function header
		strcat(buf,"void _");
		strcat(buf,bloques[i]->etiqueta);
		strcat(buf,"(){\n");

        for (j=0;j<bloques[i]->nInstrucciones;j++) {
			strcat(buf,instructionToC(bloques[i]->instrucciones[j]));
            printf("\n");
        }

		// function tail

		strcat(buf,"\n}\n\n");
    }
	return strdup(buf);
}

int main(int argc, char** argv){
	
	yyparse();
	printASMCode();

	printf("\n\nC CODE\n");
	printf("%s\n",cHeaders());
	printf("%s\n",asmDataToC());
	printf("%s\n",registerDeclarations());
	printf("%s\n",cFuncHeaders());
	printf("%s\n",cMain());
	printf("%s\n",blocksToFuctions());

    return 0;
}
void yyerror (char const *message) {
	fprintf(stderr, "%s\n",message);
}
