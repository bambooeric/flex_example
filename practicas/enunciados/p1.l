%{
#include<stdio.h>

char* dni[100];
char* nombre[100];
char* nota[100];
int l = 0;
int ok[100];
int lok=0;

int dniok[100] = {0};
int nombreok[100] = {0};
int notaok[100]= {0};

char* asignatura;
char* curso;
int headerok = 0;

%}

%start V1 S1
%x V2 S2 S3

DIGIT [0-9]
ALPHA [A-Za-záéíóúñÁÉÍÓÚ]
WORD {ALPHA}*
%%

^({WORD}" ")* {
	if(l==0){
		asignatura = strdup(yytext);
		BEGIN(S1);
	}
}
<S1>"- "{WORD}" " {
	if(l==0){
		BEGIN(S2);
	}
}

<S2>{DIGIT}{DIGIT}{DIGIT}{DIGIT}"/"{DIGIT}{DIGIT}{DIGIT}{DIGIT}\n {
	if(l==0){
		curso = strdup(yytext);
		l++;
		BEGIN(S3);
	}
}

<S3>"NIF Apellido1 Apellido2, Nombre Nota" {
	if(l==1){
		headerok = 1;
		BEGIN(INITIAL);
	}
}

^{DIGIT}{8}"-"{ALPHA} {

		dni[l] = strdup(yytext);
		dniok[l] = 1;
		BEGIN(V1);
	}
<V1>" "{WORD}" "{WORD}", "{WORD} {

		nombre[l] = strdup(yytext);
		nombreok[l] = 1;
		BEGIN(V2);
	}
<V2>" "[0-1]{0,1}{DIGIT}"."{DIGIT}{1,2} {
		nota[l] = strdup(yytext);
		notaok[l] = 1;
		ok[lok]=l;
		lok++;
		BEGIN(INITIAL);
	}

\n {
		l++;
	}

<<EOF>> {return 0;} 

%%
main(){
	yylex();

	if(headerok){
		printf("- Asignatura: %s\n", asignatura);
		printf("- Curso: %s",curso);
	}

	int i;
	printf("- Alumnos suspensos:\n");
	for(i=0;i<lok;i++){
		int x = ok[i];
		if(atof(nota[x])<5.0f)
			printf("%s;%s\n",dni[x],nombre[x]+1);
	}
	printf("- Alumnos aprobados:\n");
	for(i=0;i<lok;i++){
		int x = ok[i];
		if(atof(nota[x])>=5.0f)
			printf("%s;%s;%2.2f\n",dni[x],nombre[x]+1,atof(nota[x]));
	}


	printf("- Errores: \n");
	for(i=2;i<l+1;i++){
		//printf("%d%d%d\n",dniok[i],nombreok[i],notaok[i]);
		if(dniok[i]==0){
			printf("Linea %d: dni incorrecto\n",i+1);
		} else
		if(nombreok[i]==0){
			printf("Linea %d: nombre incorrecto\n",i+1);
		} else 
		if(notaok[i]==0){
			printf("Linea %d: nota incorrecta\n",i+1);
		}
	}


}

