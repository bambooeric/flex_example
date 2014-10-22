%{
unsigned chars=0; unsigned words=0; unsigned lines=0;
%}

COMMENT ^"/*""/"*([^*/]|[^*]"/"|"*"[^/])*"*"*"*/"\n
WORD [^ \t\n]+
EOL \n
%%
{COMMENT} {}
{WORD} {words++; chars+= yyleng;}
{EOL} {lines++;}
. {chars++;}
%%
main()
{
    yylex();
    printf("%d chars in %d words in %d lines\n",chars, words, lines);

    return 0;
}
