#include <stdlib.h>
#include <stdio.h>

int a[] = {1};
int b[] = {2};

int a0,a1,a2,a3,a4,v0;

void _main();
void _menor();

void _main(){	

	a0 = (int) &a;	//la
	a1 = (int) &b;	//la

	a2 = ((int *)a0)[0];	//lw
	a3 = ((int *)a1)[0];	//lw

	if(a2<a3) 		//slt
		a4 = 1;
	else 	
		a4 = 0;

	if(a4!=0)		//bne
		_menor();


	exit(0);
}

void _menor(){
	a0 = 0 + 1;	//addi
	v0 = 0 + 1;	//addi
	if(v0==1) printf("%d\n",a0);	//syscall
	
	exit(0);
}

int main(){
	_main();
	return 0;
}

