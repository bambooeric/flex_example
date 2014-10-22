%{
#include <stdio.h>
int numMedidas = 0;

void yyerror (char const *);
%}
%union{
	int valInt;
	float valFloat;
}
%token CENTIGRADOS FARENHEIT
%token <valInt> HORA
%token <valFloat> VALOR_TEMPERATURA
%type <valFloat> temperatura medicion lista_temperaturas
%start S
%%
S : lista_temperaturas {printf("Temperatura Media en Total: %f C\n",$1/(float)numMedidas);} 
	;
lista_temperaturas : lista_temperaturas medicion {$$ = $1 + $2; numMedidas++;}
	| medicion {$$ = $1; numMedidas++;}
	;
medicion : HORA temperatura {if ($1 == 12) {
				printf ("Temperatura a las 12H: %f C\n", $2);
			}
			$$ = $2;}
	;
temperatura : VALOR_TEMPERATURA CENTIGRADOS {$$ = $1;}
	| VALOR_TEMPERATURA FARENHEIT {$$ = (($1 - 32.0) * 5.0) / 9.0;}
	;
%%
int main() {
	yyparse();
	return 0;
}
void yyerror (char const *message) { fprintf (stderr, "%s\n", message);}


