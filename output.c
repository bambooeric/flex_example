#include <stdlib.h>
#include <stdio.h>

// zona de datos
int a[] = {1, 2, 3, 4};
int b[] = {1, 2, 3, 4};

// Declaraciones de registros referenciados en el código MIPS
int a0, a2, a1, v0;

// cabeceras de funciones que representan bloques de código MIPS
void _main();
void _etiqueta2();

// Llamada al bloque inicial
int main(){
	_main();
	return 0;
}
// Funciones que representan cada bloque de código MIPS
void _main(){
	a0 = (int) &a;
	a2 = ((int*)a0)[0/4];
	a1 = 0 + a2;
	a2 = ((int*)a0)[4/4];
	a1 = a1 + a2;
	a2 = ((int*)a0)[8/4];
	a1 = a1 + a2;
	a2 = ((int*)a0)[12/4];
	a1 = a1 + a2;
	a0 = 0 + a1;
	v0 = 0 + 1;
	if(v0==1) printf("%d\n",a0);
}

void _etiqueta2(){
	a2 = a2 + a2;
}


