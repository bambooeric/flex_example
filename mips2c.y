%error-verbose

%{

#include<stdlib.h>
#include<stdio.h>
#include<string.h>

#define foreach( idxtype , idxpvar , col , colsiz ) idxtype* idxpvar; for( idxpvar=col ; idxpvar < (col+(colsiz)) ; idxpvar++)

#define MAX_INSTRUCCIONES 1024
#define MAX_DATA_SIZE 256
#define MAX_DATA_VARS 32
#define MAX_BLOQUES 32
#define OUTPUT_FILENAME "output.c"

#define MAX_INST_SIZE 1024

extern int yylineno;


struct Args{
	char* args[3];
};

struct Instruccion{
	char* codigo;
	char* args[3]; // Esto debería ser un "struct Args*" pero me confundí y cuando me di cuenta requería demasiados cambios 
				   // como para que me diese tiempo a hacerlos antes de la entrega
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
		   									vectores[nVectores].nombre = $1;
		   									vectores[nVectores].tipo = $2;
											nVectores++;
		   								}
;
valores : VALOR 						{
											int nValores = vectores[nVectores].nValores;
											vectores[nVectores].valor[nValores] = $1;
											vectores[nVectores].nValores++;
										}
	| VALOR C valores 					{
											int nValores = vectores[nVectores].nValores;
											vectores[nVectores].valor[nValores] = $1;
											vectores[nVectores].nValores++;
										}
;
text : TEXT EOL globl    				{/*printf("-- seccion text\n");*/}
;
globl : GLOBL ETIQ EOL bloques 			{/*printf("-- bloque inicial\n");*/
	  										bloqueInicial = $2;
										}
;
bloques : ETIQPP EOL instrucciones EOL  {//printf("-- bloque de instrucciones\n");
	   										struct Bloque* bloque = (struct Bloque*) malloc(sizeof(struct Bloque));
											bloque->etiqueta = $1;

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
											bloque->etiqueta = $2;

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
											instruccion->codigo = $1;

											if($2->args[0]!=NULL) instruccion->args[0] = $2->args[0]; else instruccion->args[0] = NULL;
											if($2->args[1]!=NULL) instruccion->args[1] = $2->args[1]; else instruccion->args[1] = NULL;
											if($2->args[2]!=NULL) instruccion->args[2] = $2->args[2]; else instruccion->args[2] = NULL;

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

											args->args[0] = $1;
											args->args[1] = $3;
											args->args[2] = $5;

											$$ = args;
										} 		   
	| OPR C OPR C VALOR 				{//printf("-- instruccion i\n");
											struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = $1;
											args->args[1] = $3;
											args->args[2] = $5;

											$$ = args;
										} 
	| OPR C VALOR P1 OPR P2				{//printf("-- instruccion con desplazamiento\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = $1;
											args->args[1] = $3;
											args->args[2] = $5;

											$$ = args;
										} 
	| OPR C OPR C ETIQ	 				{//printf("-- instruccion salto cond\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = $1;
											args->args[1] = $3;
											args->args[2] = $5;

											$$ = args;
										} 
	| ETIQ 								{//printf("-- instruccion salto\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = $1;
											args->args[1] = NULL;
											args->args[2] = NULL;


											$$ = args;
										} 
	| OPR C ETIQ						{//printf("-- instruccion la\n");
		   									struct Args* args = (struct Args*) malloc(sizeof(struct Args));

											args->args[0] = $1;
											args->args[1] = $3;
											args->args[2] = NULL;

											$$ = args;
										} 
;
%%

/*
 * Recorre la estructura parseada y la muestra formateada por pantalla.
*/
void printASMCode(){
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

/*
 * Genera la cabecera del código C, incluyendo las librerías stdlib y stdio 
 */
char* cHeaders(){
	char* buf =  "#include <stdlib.h>\n#include <stdio.h>\n";
	return strdup(buf);
}

/*
 * Define los vectores de datos parseados en el código MIPS a vectores
 * estáticos definidos como variable global con sintaxis C
*/
char* asmDataToC(){
	int i,j;
	char buf[MAX_DATA_SIZE * MAX_DATA_VARS];
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


// Dice si un char* contiene un registro (es decir, si empieza por "$" y tiene longitud 3
int isRegister(char* inst){
	char _i = inst[0];

	if((strlen(inst)==3) && (_i == '$'))
		return 1;
	else 
		return 0;
}

// Añade un char* a un array de char*
char** arrAppend(char** arr, char* e, int arrlen){
	char** arr2 = malloc((arrlen + 1) * sizeof(char*)); //lenth of the older array + 1 char* items
	memcpy(arr2,arr,arrlen * sizeof(char*));            //copy older array
	arr2[arrlen] = strdup(e);                           //copy new array in the last
	free(arr);                                          //and cleanup
	return arr2;
} 

// Dice si un argumento está dentro de la lista de argumentos por declarar, para no repetir ninguno.
int declaredArg(char** declared,int dec_len, char* inst){
	foreach(char*, arg, declared,dec_len){ // Esto es un #define arriba.
		if((strcmp(*arg,inst)==0)){
			return 1;
		}
	}
	return 0;
}

/*
 * Declara los registros MIPS con sintáxis C
 * Los registros en MIPS tienen visibilidad en todo el código, por tanto todos los registros
 * referenciados serán declarados como variables globales en el código C.
*/
char* registerDeclarations(){
	/* Recorrer las instrucciones mips y almacenar todos los registros referenciados
	 * en algún punto del código. 
	*/
	char** declared = 0;
	int dec_len = 0;
	int i,j,k;
    for (i=0;i<nBloques;i++) {
        for (j=0;j<bloques[i]->nInstrucciones;j++) {
            k = 0;
            while (k < 3 && bloques[i]->instrucciones[j]->args[k] != NULL) {
				// Duplicamos esta memoria para no liarla al desplazar despues el registro
				char* inst = strdup(bloques[i]->instrucciones[j]->args[k++]);
				if (isRegister(inst)){
					if (!declaredArg(declared, dec_len, inst)){
						declared = arrAppend(declared,inst,dec_len);
						dec_len++;
					}
				}
				free(inst);
            }
        }
    }
	
	/*
	 * Declarar todas estas variables en la sintáxis de C. Esta parte del código
	 * deberá ser editada si en un futuro se quisiera dar soporte a más tipos de 
	 * datos además de "int"
	*/
	char buf[2048];

	strcpy(buf,"// Declaraciones de registros referenciados en el código MIPS\n");
	strcat(buf,"int ");
	i=0;
	foreach(char*, inst, declared, dec_len){ // Esto es una macro definida arriba para simplificar las cosas...
        strcat(buf, ++*inst);
		// Igual es una forma de liberar la memoria algo turbia... Pero estos registros están desplazados en este punto
		free(--*inst);	
		i++;
		if(i<dec_len) strcat(buf,", ");
	}
	// Esto ya no volverá a ser necesario
	free(declared);
	strcat(buf,";\n");

	return strdup(buf);
}
/*
 * Genera el código C correspondiente a la llamada al bloque inicial.
 * El código debe empezar donde sea la etiqueta inicial de la sección .text en mips, y no 
 * es necesariamente el primero por tanto es necesaria esta primera llamada al primer bloque.
*/
char* cMain(){
	char buf[2048];

	strcpy(buf,"// Llamada al bloque inicial\n");
	strcat(buf,"int main(){\n\tgoto _");
	strcat(buf,bloqueInicial);
	strcat(buf,";\n");

	return strdup(buf);
}

char* cTail(){
	char buf[64];

	strcpy(buf,"\treturn 0;\n}\n");

	return strdup(buf);
}

/*
 * Recibe la estructura correspondiente a una instrucción MIPS y la traduce a código C. 
*/
char* instructionToC(struct Instruccion* _inst){
	char buf[MAX_INST_SIZE];
	struct Instruccion* inst = (struct Instruccion*) malloc(sizeof(struct Instruccion));
	memcpy(inst,_inst,sizeof(struct Instruccion));

	strcpy(buf,"\t");
	if(strcmp(inst->codigo, "la")==0){	// la $a0, a => a0 = (int) &a
		/*
		* El cast a entero producirá un warning in sistemas de 64 bits.
		* Se tomó int como tipo base porque los registros mips son de 32 bits. Este warning es aceptable y controlado.
		*/
		strcat(buf,++(inst->args[0]));
		strcat(buf," = (int) &");
		strcat(buf,(inst->args[1]));
	}else
	if(strcmp(inst->codigo, "add")==0){ // add $a1, $a2, $a3 => a1 = a2 + a3
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ");
		strcat(buf,++(inst->args[1]));
		strcat(buf," + ");
		strcat(buf,++(inst->args[2]));
	}else
	if(strcmp(inst->codigo, "and")==0){ // and $a1, $a2, $a3 => a1 = a2 & a3
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ");
		strcat(buf,++(inst->args[1]));
		strcat(buf," & ");
		strcat(buf,++(inst->args[2]));
	}else
	if(strcmp(inst->codigo, "or")==0){ // or $a1, $a2, $a3 => a1 = a2 | a3
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ");
		strcat(buf,++(inst->args[1]));
		strcat(buf," | ");
		strcat(buf,++(inst->args[2]));
	}else
		if(strcmp(inst->codigo, "lw")==0){ // lw $a1, 0($a2) => a1 = ((int*) a2)[0/4]
		/*
		* Esto deberá ser corregido si en un futuro se quiere dar soporte a mas tipos de datos
		* que los enteros de MIPS. La expresión [0/4] desplazará el puntero suponiendo que el tipo
		* de dato al que se está accediendo es un entero.
		*/
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ((int*)");
		strcat(buf,++(inst->args[2]));
		strcat(buf,")[");
		strcat(buf,inst->args[1]);
		strcat(buf,"/4]");
	}else
	if(strcmp(inst->codigo, "sw")==0){ // sw $a1, 0($a2) => ((int*) a2)[0/4] = a1
		// El mismo "problema" que la instrucción anterior.
		strcat(buf,"((int*)");
		strcat(buf,++(inst->args[2]));
		strcat(buf,")[");
		strcat(buf,inst->args[1]);
		strcat(buf,"/4]");
		strcat(buf," = ");
		strcat(buf,++(inst->args[0]));
	}else
	if(strcmp(inst->codigo, "addi")==0){ // addi $a1, $a2, 1 => a1 = a2 + 1
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ");
		strcat(buf,++(inst->args[1]));
		strcat(buf," + ");
		strcat(buf,inst->args[2]);
	}else
	if(strcmp(inst->codigo, "andi")==0){ // andi $a1, $a2, 1 => a1 = a2 & 1
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ");
		strcat(buf,++(inst->args[1]));
		strcat(buf," & ");
		strcat(buf,inst->args[2]);
	}else
	if(strcmp(inst->codigo, "ori")==0){ // ori $a1, $a2, 1 => a1 = a2 | 1
		strcat(buf,++(inst->args[0]));
		strcat(buf," = ");
		strcat(buf,++(inst->args[1]));
		strcat(buf," | ");
		strcat(buf,inst->args[2]);
	}else
	if(strcmp(inst->codigo, "slt")==0){ // slt $a1, $a2, $a3 => if(a2<a3) a1 = 1
		strcat(buf,"if(");
		strcat(buf,++(inst->args[1]));
		strcat(buf," < ");
		strcat(buf,++(inst->args[2]));
		strcat(buf,")\n\t\t");
		strcat(buf,++(inst->args[0]));
		strcat(buf," = 1;\n\telse\n\t\t");
		strcat(buf,inst->args[0]);// aqui el puntero ya está desplazado
		strcat(buf," = 0");
	}else
	if(strcmp(inst->codigo, "slti")==0){ // slt $a1, $a2, 1 => if(a2<1) a1 = 1
		strcat(buf,"if(");
		strcat(buf,++(inst->args[1]));
		strcat(buf," < ");
		strcat(buf,inst->args[2]);
		strcat(buf,")\n\t\t");
		strcat(buf,++(inst->args[0]));
		strcat(buf," = 1;\n\telse\n\t\t");
		strcat(buf,inst->args[0]);// aqui el puntero ya está desplazado
		strcat(buf," = 0");
	}else
	if(strcmp(inst->codigo, "bne")==0){ // bne $a1, $a2, etiqueta => if(a1!=a2) goto etiqueta
		strcat(buf,"if(");
		strcat(buf,++(inst->args[0]));
		strcat(buf," != ");
		strcat(buf,++(inst->args[1]));
		strcat(buf,")\n\t\tgoto _");
		strcat(buf,inst->args[2]);
	}else
	if(strcmp(inst->codigo, "beq")==0){ // beq $a1, $a2, etiqueta => if(a1==a2) goto etiqueta
		strcat(buf,"if(");
		strcat(buf,++(inst->args[0]));
		strcat(buf," == ");
		strcat(buf,++(inst->args[1]));
		strcat(buf,")\n\t\tgoto _");
		strcat(buf,inst->args[2]);
	}else
	if(strcmp(inst->codigo, "j")==0){
		strcat(buf,"goto _");
		strcat(buf,inst->args[0]);
	}else
	if(strcmp(inst->codigo, "SYSCALL")==0){ // switch con todos los posibles valores de v0 para syscall
		/*
		* Esta probablemente no sea la mejor manera de hacerlo. Lo más correcto sería traducir directamente
		* por la instrucción que corresponda, analizando el código MIPS y buscando el valor en este momento del
		* registro $v0, y haciendo el switch aqui para generar directamente la instrucción correspondiente. 
		* Se hizo de este modo por falta de tiempo.
		*/
		strcat(buf,"switch (v0){\n");
		strcat(buf,"\tcase 1:\n\t\tprintf(\"\%d\\n\",a0);\n\t\tbreak;\n");
		strcat(buf,"\tcase 10:\n\t\texit(0);\n\t\tbreak;\n");
		strcat(buf,"\tdefault:\n\t\tprintf(\"Syscall not implemented yet\\n\");\n\t\texit(1);\n\t}");
	}else{
		printf(">> UNIMPLEMENTED ASM FUNCTION <%s>. ABORTING\n",inst->codigo);
		exit(1);
	}

	strcat(buf,";\n");
	free(inst);
	return strdup(buf);
}

/*
 * Traduce cada una de las etiquetas del código MIPS por orden, para asegurarse que no se sobreescribe 
 * ninguna palabra reservada de C los nombres de las etiquetas empezarán siempre por "_".
*/
char* blocksToFuctions(){
	char buf[MAX_INST_SIZE*MAX_BLOQUES + 256]; // Reservamos un poco de más para la parte inicial, final y la etiqueta inicial
	strcpy(buf, "// Funciones que representan cada bloque de código MIPS\n");

    int i,j,k;
    for (i=0;i<nBloques;i++) {
		// function header
		strcat(buf,"_");
		strcat(buf,bloques[i]->etiqueta);
		strcat(buf,":\n");

        for (j=0;j<bloques[i]->nInstrucciones;j++) {
			strcat(buf,instructionToC(bloques[i]->instrucciones[j]));
        }

		// function tail

		strcat(buf,"\n\n");
    }
	return strdup(buf);
}
/*
 * Libera la memoria reservada por el parser al crear las estructuras con las instrucciones MIPS
 * El código es un poco confuso porque algunas estructuras están definidas como estáticas y otras
 * como dinámicas. Se debería corregir esto para dar un código más facilmente mantenible.
*/
void freeStructures(){
    int i,j,k;

	// Bloques de código
    for (i=0;i<nBloques;i++) {
        for (j=0;j<bloques[i]->nInstrucciones;j++) {
            free(bloques[i]->instrucciones[j]->codigo);
            k = 0;
            while (k < 3 && bloques[i]->instrucciones[j]->args[k] != NULL) {
                free( bloques[i]->instrucciones[j]->args[k++]);
            }

        }

		//free(bloques[i]->instrucciones[j]);
		free(bloques[i]->etiqueta);
		free(bloques[i]);
    }

	// Definiciones de datos
	for (i=0; i<nVectores; i++){
		free(vectores[i].nombre);
		free(vectores[i].tipo);
		for(j=vectores[i].nValores - 1; j>=0; j--){
			free(vectores[i].valor[j]);
		}
	}


	free(bloqueInicial);
}

int main(int argc, char** argv){
	
	// Ejecutamos el parser y almacenamos en memoria la estructura de instrucciones MIPS
	printf("\n>> STEP 1: PARSING SOURCE ASM CODE...\n");
	if(yyparse()){
		printf("Couldn`t parse file. Exiting...\n");
	}

	printf(">> done!\n");
	printf(">> DETECTED ASM CODE:\n");

	// Mostramos el cógido detectado. Si llega aquí se supone que la sintaxis es correcta
	printASMCode();

	printf("\n>> %d lines of ASM code successfully analyzed",yylineno-1);
	printf("\n>> STEP 2: TRANSLATING C CODE...\n");

	/* Generamos el código en C a partir de las estructuras parseadas.
	 * Se hace de este modo porque algunas de las funciones desplazan los punteros para tomar el valor de los registros
	 * necesarios, y si el código se sigue ejecutando antes que la llamada al sistema para escribir en el fichero puede
	 * producir violaciones de segmento
	*/
 	char* b1 = cHeaders();
	char* b2 = asmDataToC();
	char* b3 = registerDeclarations();
	char* b4 = cMain();
	char* b5 = blocksToFuctions();
	char* b6 = cTail();

	// Abrimos un archivo nuevo y escribimos el contenido generado por estas funciones en orden
	printf("\n>> STEP 3: GENERATING C CODE...\n");
	FILE *fp;
   	fp = fopen(OUTPUT_FILENAME, "w");
    fprintf(fp, "%s\n%s\n%s\n%s\n%s\n%s\n",b1,b2,b3,b4,b5,b6);
	fclose(fp);
	printf(">> Saved file as \"%s\"\n",OUTPUT_FILENAME);
	printf("\n>> STEP 4: FINISHING...\n");

	// Limpiamos "toda" la memoria reservadaantes de salir.
	free(b1);
	free(b2);
	free(b3);
	free(b4);
	free(b5);
	free(b6);
	freeStructures();

	printf("\n>> DONE!\n");
    return 0;
}

void yyerror (char const *message) {
	fprintf(stderr, ">> %s near line %d\n>> Couldn`t parse file. Exiting...\n",message, yylineno);
	exit(1);
}
