#include <stdlib.h>
#include <stdio.h>

int a[] = {1,2,3,4};
int b[] = {1,2,3,4};

int a0,a1,a2,v0;

void _main();
void _etiqueta2();

void _main(){	

	a0 = (int) &a;	//la

	a2 = ((int *)a0)[0];	//lw
	a1 = 0 + a2; //add

	a2 = ((int *)a0)[4/4];	//lw
	a1 = a1 + a2;

	a2 = ((int *)a0)[8/4];	//lw
	a1 = a1 + a2;

	a2 = ((int *)a0)[12/4];	//lw
	a1 = a1 + a2;

	a0 = 0 + a1;	//add
	v0 = 0 + 1;	//addi
	if(v0==1) printf("%d\n",a0);	//syscall
}

void _etiqueta2(){
	a2 = a2 + a2;
}

int main(){
	_main();
	return 0;
}

/*
 * Imprimir cabeceras include
 * Recorrer seccion .DATA y declararlos como
 * 		tipo nombre "[]" = "{"datos con comas "}" ";"
 * Buscar todos los registros referenciados y declararlos
 * 		int registros con comas ";"
 * Buscar todos las etiquetas de bloques y declararlas
 * 		"void" "_"etiqueta"();"
 * Para cada bloque definir una función que lo contiene
 * 		"void _"etiqueta"(){"
 * 			para cada instruccion del bloque - mostrar instruccion ";"
 * Definir bloque main
 * 		"int main(){"
 * 			"_"bloqueInicial"();"
 * 		"return 0;}"
 *
 *
 * */
