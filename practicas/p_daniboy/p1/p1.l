%{
int caracteres = 0, palabras = 0, mayusculas = 0, minusculas=0, frases=0;
%}
punto \.
coma \,
puntocoma \;
dospuntos \:
palabra [^ \t\n\.\,\;\:]+
mayuscula [A-Z]+
minuscula [a-z]+
frasemin {minuscula}\.
frasemay {mayuscula}\.
frase {palabra}\.
%%
{coma}		{caracteres+=yyleng;}
{puntocoma}	{caracteres+=yyleng;}
{dospuntos}	{caracteres+=yyleng;}
{punto}{3}  {caracteres+=yyleng;}
{punto}		{frases++;caracteres+=yyleng;}
{mayuscula} {mayusculas++;palabras++;caracteres+=yyleng;}
{minuscula}	{minusculas++;palabras++;caracteres+=yyleng;}
{palabra}	{palabras++;caracteres+=yyleng;}

. {}
%%
main() {
	yylex();
	printf("Caracteres: %d\n",caracteres);
	printf("Palabras: %d\n",palabras);
	printf("Mayusculas: %d\n",mayusculas);
	printf("Minusculas: %d\n",minusculas);
	printf("Frases: %d\n",frases);
}
