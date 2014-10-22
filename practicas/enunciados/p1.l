%{
#include<stdio.h>

char* dni[100];
char* nombre[100];
char* nota[100];
int l = 0;

%}

%start V1
%x V2

DIGIT [0-9]
ALPHA [A-Za-záéíóúñÁÉÍÓÚ]
WORD {ALPHA}*
%%

^{DIGIT}{8}"-"{ALPHA} {

		dni[l] = strdup(yytext);
		BEGIN(V1);
	}
<V1>" "{WORD}" "{WORD}", "{WORD} {

		nombre[l] = strdup(yytext);
		BEGIN(V2);
	}
<V2>" "[0-1]{0,1}{DIGIT}"."{DIGIT}{1,2} {
		nota[l] = strdup(yytext);
		BEGIN(INITIAL);
	}

\n {
		l++;
		printf("BARRANEN\n");
	}

<<EOF>> {return 0;} 

%%
main(){
	yylex();
	printf("%s\n",dni[2]);
	l++;



}

