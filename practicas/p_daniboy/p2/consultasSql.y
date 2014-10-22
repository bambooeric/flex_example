%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tiposDatos.h"

#define NEMP 100

void yyerror (const char *s);
//devuelve el campo num de una linea de un archivo .csv
char* getfield(char* line, int num);
int leerfichero(FILE *f, empleado empleados[NEMP]);
//elimina las comillas de un string 
void eliminar_comillas(char *str);
// comprueba la condicion del where
int comprobarcondicion(int i, Condicion condicion);
//funcion que compara dos enteros siendo a > b
int tipocampo(Operando op);
int comprobartipo(Operando op1, Operando op2, int *tipo, int *campo);
void consultaselect(char *str);
Valor obtenervalor(int i, char *campo);
int comprobarcondicion(int i,Condicion c);
void consulta(Condicion condicion);

int nempleados; //numero de empleados
empleado empleados[NEMP];
//cada posicion del vector representa si es un campo de la consulta
int campo[6] = {0,0,0,0,0,0};
Operando operador1, operador2;
Valor valorconsulta;
%}
%union{
	int entero;
	char *str;
	float real;
	char caracter;
	Operando toperando;
	Condicion tcondicion;
}
//%error-verbose
%token <str> IDEMPLEADO NOMBRE PUESTO CAMPOCORREO ANHO SALARIO
%token SELECT FROM WHERE PUNTOCOMA COMA ASTERISCO 
%token <caracter> MENOR MAYOR IGUAL
%token <entero> ENTERO
%token <str> STRING STRESPACIO CORREO
%token <real> REAL
%type <str> consulta tabla
%type <toperando> valor campo operando 
%type <tcondicion> condicion
%type <caracter> operador
%start S
%%
S: SELECT consulta FROM tabla WHERE condicion PUNTOCOMA{
	 	consulta($6);
	 	exit(0);
	}
	| error{
		yyerror("La consulta está mal formada");
		exit(0);
	};

consulta: ASTERISCO{
		campo[0] = 1;
		campo[1] = 1;
		campo[2] = 1;
		campo[3] = 1;
		campo[4] = 1;
		campo[5] = 1;
	}
	|  campo{
		consultaselect($1.valor.string);
	}
	|	consulta COMA campo{
		consultaselect($3.valor.string);
	};
	
tabla: STRING{
	if(strcmp($1,"empleados")!=0) {
		yyerror("La tabla no existe");
		exit(0);
	}
};

condicion: operando operador operando {
		int tipo,campo;
		if(comprobartipo($1,$3,&tipo,&campo)) {		
			$$.tipovalor = tipo;
			$$.campo = campo;
			// si el campo es el segundo operando se invierte al operando1
			// y el operador al contrario
			if(campo == 2) {
				$$.op1 = $3;
				$$.op2 = $1;
				if ($2=='<') {
					$$.operador = '>';
				}else if ($2=='>') {
					$$.operador = '<';
				}else {
					$$.operador = $2;
				}
			}else {
				$$.op1 = $1;
				$$.op2 = $3;
				$$.operador = $2;
			}
		}else {
			yyerror("Error en comparacion de tipos de datos");
			exit(0);
		}
	};

operando: valor{ $$ = $1; }
	| campo{ $$ = $1; };

operador: MENOR{ $$ = $1; }
	| MAYOR{	$$ = $1; }
	| IGUAL{ $$ = $1; }
	| error{
		yyerror("Operador desconocido");
		exit(0);
	};
	
campo: IDEMPLEADO{
		$$.tipovalor = CAMPO;
		$$.valor.string = strdup($1);
	} 
	| NOMBRE{
		$$.tipovalor = CAMPO;
		$$.valor.string = strdup($1);
	} 
	| PUESTO{
		$$.tipovalor = CAMPO;
		$$.valor.string = strdup($1);
	} 
	| CAMPOCORREO{
		$$.tipovalor = CAMPO;
		$$.valor.string = strdup($1);
	} 
	| ANHO{
		$$.tipovalor = CAMPO;
		$$.valor.string = strdup($1);
	}
	| SALARIO{
		$$.tipovalor = CAMPO;
		$$.valor.string = strdup($1);
	}
	| error{
		yyerror("Campo invalido");
		exit(0);
	};

valor: STRING{
		$$.tipovalor = STR;
		$$.valor.string = strdup($1);
	}
	| STRESPACIO{
		$$.tipovalor = STR;
		$$.valor.string = strdup($1);
		eliminar_comillas($$.valor.string);
	}
	| CORREO {
		$$.tipovalor = STR;
		$$.valor.string = strdup($1);
	} 
	| ENTERO{
		$$.tipovalor = INT;
		$$.valor.entero = $1;
	} 
	| REAL{
		$$.tipovalor = FLOAT;
		$$.valor.real = $1;
	};
			
%%
void yyerror (const char *s) {
	if (strcmp(s,"syntax error")!=0) {
   	fprintf (stderr, "***%s\n", s);
   }
}

//obtiene un campo de una linea en formato CSV
char* getfield(char* line, int num) {
	char* tok;
    for(tok=strtok(line, ",");tok && *tok;tok = strtok(NULL, ",\n")) {
        if(!--num) {
            return tok;
        }
    }
    return NULL;
}

//lee el fichero y almacena cada campo en la estructura correspodiente
int leerfichero(FILE *f, empleado empleados[NEMP]) {
	char linea[200];
	int i = 0;
	
	while(fgets(linea, 200,f)) {
		char *tmp = strdup(linea);
		
		empleados[i].idEmpleado = atoi(getfield(tmp,1));
		tmp = strdup(linea);
		empleados[i].nombre = getfield(tmp,2);
		tmp = strdup(linea);
		empleados[i].puesto = getfield(tmp,3);
		tmp = strdup(linea);
		empleados[i].correo = getfield(tmp,4);
		tmp = strdup(linea);
		empleados[i].anho = getfield(tmp,5);
		tmp = strdup(linea);
		empleados[i].salario = atof(getfield(tmp,6));
		
		free(tmp);
		i++;
	}
	return i;
}

//elimina las comillas de un string 
void eliminar_comillas(char *str) {
	int i,l = strlen(str);
	
	for(i=0;i<(l-1);i++) {
		str[i]=str[i+1];
	} 
	str[l-2] = '\0';
}

// selecciona en el vector de consulta todos los campos a imprimir
void consultaselect(char *str) {
	if(strcmp(str,"idEmpleado")==0) {
		campo[0] = 1;
	}
	if(strcmp(str,"nombre")==0) {
		campo[1] = 1;
	}
	if(strcmp(str,"puesto")==0) {
		campo[2] = 1;
	}
	if(strcmp(str,"correo")==0) {
		campo[3] = 1;
	}
	if(strcmp(str,"anho")==0) {
		campo[4] = 1;
	}
	if(strcmp(str,"salario")==0) {
		campo[5] = 1;
	}
}

//dado un identificador de campo devuelve el tipo que guarda
int tipocampo(Operando op) {
	if(strcmp(op.valor.string,"idEmpleado")==0) {
		return INT;
	}
	if(strcmp(op.valor.string,"nombre")==0 ||
		strcmp(op.valor.string,"puesto")==0 ||
		strcmp(op.valor.string,"correo")==0 ||
		strcmp(op.valor.string,"anho")==0) {
		return STR;	
	}
	if(strcmp(op.valor.string,"salario")==0) {
		return FLOAT;
	}
}

// comprueba que los tipos de datos sean compatibles
int comprobartipo(Operando op1, Operando op2, int *tipo, int *campo) {
	if(op1.tipovalor==CAMPO) { // primer operando campo
		if(op2.tipovalor==CAMPO){ // segundo operando campo
			*tipo=op2.tipovalor;
			*campo=3;
			return 1;
		}else { //seguno operando valor
			if (tipocampo(op1)==FLOAT) {
				if (op2.tipovalor==FLOAT || op2.tipovalor==INT) {
					*tipo=FLOAT;
					*campo=1;
					return 1;
				}
			}else if(tipocampo(op1)==op2.tipovalor) {
				*tipo=op2.tipovalor;
				*campo=1;
				return 1;
			}
		}
	}else{// primer operando valor
		if(op2.tipovalor==CAMPO){ // segundo operando campo
			if(tipocampo(op2)==FLOAT) {
				if (op1.tipovalor==FLOAT || op1.tipovalor==INT) {
					*tipo=FLOAT;
					*campo=2;
					return 1;
				}
			}else if(op1.tipovalor==tipocampo(op2)){
				*tipo=op1.tipovalor;
				*campo=2;
				return 1;
			}
		}else { // segundo operando valor
			if (op1.tipovalor==FLOAT) {
				if (op2.tipovalor==FLOAT || op2.tipovalor==INT){
					*tipo = FLOAT;
					*campo = 0;
					return 1;
				}
			}
			if (op2.tipovalor==FLOAT) {
				if (op1.tipovalor==FLOAT || op1.tipovalor==INT) {
					*tipo = FLOAT;
					*campo = 0;
					return 1;
				}
			}
			if(op1.tipovalor == op2.tipovalor) {
				*tipo=op1.tipovalor;
				*campo=0;
				return 1;
			}
		}
	}
	return 0;
}

// imprime la cabecera en funcion de los campos seleccionados
void cabecera() {
	if(campo[0]) {
		printf("ID |");
	}
	if(campo[1]) {
		printf("  nombre  |");
	}
	if(campo[2]) {
		printf("        puesto       |");
	}
	if(campo[3]) {
		printf("      correo       |");
	}
	if(campo[4]) {
		printf(" anho |");
	}
	if(campo[5]) {
		printf(" salario ");
	}
	printf("\n-------------------------------------------------------------------------\n");
}

//obtiene el valor asociado a un campo
Valor obtenervalor(int i, char *campo) {
	Valor aux;
	if(strcmp(campo,"idEmpleado")==0) {
		aux.entero = empleados[i].idEmpleado;
	}else if(strcmp(campo,"nombre")==0) {
		aux.string = empleados[i].nombre;
	}else if(strcmp(campo,"puesto")==0) {
		aux.string = empleados[i].puesto;
	}else if(strcmp(campo,"correo")==0) {
		aux.string = empleados[i].correo;
	}else if(strcmp(campo,"anho")==0) {
		aux.string = empleados[i].anho;
	}else if(strcmp(campo,"salario")==0) {
		aux.real = empleados[i].salario;
	}
	return aux;
}

// comprueba que la condicion del where sea cierta
int comprobarcondicion(int i,Condicion c) {
	if(c.campo==0) {
		switch(c.operador) {
			case '>':
				if(c.tipovalor==INT) {
					return c.op1.valor.entero > c.op2.valor.entero;
				}
				if(c.tipovalor==FLOAT) {
					//permitimos comparar un float con un int dado
					if(c.op1.tipovalor==INT) {
						return c.op1.valor.entero > c.op2.valor.real;
					}
					if(c.op2.tipovalor==INT) {
						return c.op1.valor.real > c.op2.valor.entero;
					}
					return c.op1.valor.real > c.op2.valor.real;
				}
				if(c.tipovalor==STR || c.tipovalor==CAMPO ) {
					return strcmp(c.op1.valor.string,c.op2.valor.string)>0;
				}
			break;
			case '<':
				if(c.tipovalor==INT) {
					return c.op1.valor.entero < c.op2.valor.entero;
				}
				if(c.tipovalor==FLOAT) {
					//permitimos comparar un float con un int dado
					if(c.op1.tipovalor==INT) {
						return c.op1.valor.entero < c.op2.valor.real;
					}
					if(c.op2.tipovalor==INT) {
						return c.op1.valor.real < c.op2.valor.entero;
					}
					return c.op1.valor.real < c.op2.valor.real;
				}
				if(c.tipovalor==STR || c.tipovalor==CAMPO ) {
					return strcmp(c.op1.valor.string,c.op2.valor.string)<0;
				}
			break;
			case '=':
				if(c.tipovalor==INT) {
					return c.op1.valor.entero == c.op2.valor.entero;
				}
				if(c.tipovalor==FLOAT) {
					//permitimos comparar un float con un int dado
					if(c.op1.tipovalor==INT) {
						return c.op1.valor.entero == c.op2.valor.real;
					}
					if(c.op2.tipovalor==INT) {
						return c.op1.valor.real == c.op2.valor.entero;
					}
					return c.op1.valor.real == c.op2.valor.real;
				}
				if(c.tipovalor==STR || c.tipovalor==CAMPO ) {
					return strcmp(c.op1.valor.string,c.op2.valor.string)==0;
				}
			break;
		}
	}else if(c.campo == 1 || c.campo == 2) {
		Valor v1 = obtenervalor(i, c.op1.valor.string);
		switch(c.operador) {
			case '>':
				if(c.tipovalor==INT) {
					return v1.entero > c.op2.valor.entero;
				}
				if(c.tipovalor==FLOAT) {
					//permitimos comparar un float con un int dado
					if(c.op2.tipovalor==INT){
						return v1.real > c.op2.valor.entero;
					}
					return v1.real > c.op2.valor.real;
				}
				if(c.tipovalor==STR || c.tipovalor==CAMPO ) {
					return strcmp(v1.string,c.op2.valor.string)>0;
				}
			break;
			case '<':
				if(c.tipovalor==INT) {
					return v1.entero < c.op2.valor.entero;
				}
				if(c.tipovalor==FLOAT) {
					//permitimos comparar un float con un int dado
					if(c.op2.tipovalor==INT){
						return v1.real < c.op2.valor.entero;
					}
					return v1.real < c.op2.valor.real;
				}
				if(c.tipovalor==STR || c.tipovalor==CAMPO ) {
					return strcmp(v1.string,c.op2.valor.string)<0;
				}
			break;
			case '=':
				if(c.tipovalor==INT) {
					return v1.entero == c.op2.valor.entero;
				}
				if(c.tipovalor==FLOAT) {
					//permitimos comparar un float con un int dado
					if(c.op2.tipovalor==INT){
						return v1.real == c.op2.valor.entero;
					}
					return v1.real == c.op2.valor.real;
				}
				if(c.tipovalor==STR || c.tipovalor==CAMPO ) {
					return strcmp(v1.string,c.op2.valor.string)==0;
				}
			break;
		}
	}else {
		switch(c.operador) {
			case '>':
				return strcmp(c.op1.valor.string,c.op2.valor.string)>0;
			break;
			case '<':
				return strcmp(c.op1.valor.string,c.op2.valor.string)<0;
			break;
			case '=':
				return strcmp(c.op1.valor.string,c.op2.valor.string)==0;
			break;
		}
	}
}

// ejecuta la consulta imprimendo el resultado por pantalla
void consulta(Condicion condicion) {
	int i;
	cabecera();
	for(i=0;i<nempleados;i++) {
		//comprueba que se cumpla la condicion para el empleado i
		int b = comprobarcondicion(i,condicion); 
	
		if(campo[0] && b) {
			printf("%3i|",empleados[i].idEmpleado);
		}
		if(campo[1] && b) {
			printf("%10s|",empleados[i].nombre);
		}
		if(campo[2] && b) {
			printf("%21.21s|",empleados[i].puesto);
		}	
		if(campo[3] && b) {
			printf("%19.19s|",empleados[i].correo);
		}
		if(campo[4] && b) {
			printf("%6s|",empleados[i].anho);
		}
		if(campo[5] && b) {
			printf("%9.2f",empleados[i].salario);
		}
		if(b) {
			printf("\n");
		}
	}
}

int main(int argc, char *argv[]) {
	FILE *f = NULL;
	
	if(argc!=2) {
		yyerror("Necesario un ficheiro de empleados\n");
		exit(0);
	}
	
	f = fopen(argv[1], "r");
	if(f==NULL) {
		yyerror("Error o abrir o ficheiro\n");
		exit(0);
	}
	
	nempleados = leerfichero(f,empleados);
	
	fclose(f);
	yyparse();
}

