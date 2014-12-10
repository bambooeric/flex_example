#include <stdlib.h>
#include <stdio.h>

// zona de datos
int a[] = {3};
int b[] = {4};

// Declaraciones de registros referenciados en el código MIPS
int a0, a1, a2, a3, a4, v0;

// cabeceras de funciones que representan bloques de código MIPS
void _main();
void _menor();

// Llamada al bloque inicial
int main(){
	_main();
	return 0;
}
// Funciones que representan cada bloque de código MIPS
void _main(){
	a0 = (int) &a;
	a1 = (int) &b;
	a2 = ((int*)a0)[0/4];
	a3 = ((int*)a1)[0/4];
	if(a2 < a3)
		a4 = 1;
	else
		a4 = 0;
	if(a4 != 0)
		_menor();

	exit(0);
}

void _menor(){
	a0 = 0 + 1;
	v0 = 0 + 1;
	if(v0==1) printf("%d\n",a0);

	exit(0);
}


