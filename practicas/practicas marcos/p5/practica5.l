%{
#include <stdio.h>
#include <string.h>

char xml=0;
char dblp=0;
char article=0;

char *key = NULL;
char *authors[255];
int a=0;
char *title = NULL;
char *pages = NULL;
char *volume = NULL;
char *journal = NULL;
char *number = NULL;
char *year = NULL;
char *ee = NULL;

void printKey(char *str)
{
    char *tok;
    char *key;
    
    tok = strtok(str," ");
    while(tok)
    {
        if(!strncmp(tok,"key",3))
        {
            key = strtok(tok,"=");
            key = strtok(NULL,"=");
            key[strlen(key)-1] = '\0';
            printf("%s,",key+1);
            return;
        }
        tok = strtok(NULL," ");
    }
}

void printWOTags(char *str)
{
    char *print;
    char *fin;
    char *tmp;
    
    print = strstr(str,">");
    print++;
    tmp = strstr(print,"<");
    while(tmp)
    {
        fin = tmp;
        tmp = strstr(tmp+1,"<");
    }
    fin[0] = '\0';
    printf("%s",print);
}

void printAuthors(char *authors[255], int a)
{
    int i;

    if(a)
    {
        printf("\t");
        printWOTags(authors[0]);
    }
    for(i=1;i<a;++i)
    {
        printf(" and\n\t\t\t");
        printWOTags(authors[i]);
    }
}
void printArticle()
{
    printf("@article{DBLP:");
    printKey(key);
    printf("\n");
    printf("\tauthor\t= {");
    printAuthors(authors, a);
    printf("},\n");
    printf("\ttitle\t= {");
    printWOTags(title);
    printf("},\n");
    printf("\tjournal\t= {");
    printWOTags(journal);
    printf("},\n");
    printf("\tvolume\t= {");
    printWOTags(volume);
    printf("},\n");
    printf("\tnumber\t= {");
    printWOTags(number);
    printf("},\n");
    printf("\tyear\t= {");
    printWOTags(year);
    printf("},\n");
    printf("\tpages\t= {");
    printWOTags(pages);
    printf("},\n");
    printf("\tee\t= {");
    printWOTags(ee);
    printf("},\n");
    printf("\tbibsource\t= {DBLP, http://dblp.uni-trier.de}\n");

    printf("}\n");
}

void resetVars()
{
    int i;
    article=0;

    key = NULL;
    for(i=0;i<a;++i)
        free(authors[i]);
    a=0;
    title = NULL;
    pages = NULL;
    volume = NULL;
    journal = NULL;
    number = NULL;
    year = NULL;
    ee = NULL;

}
%}

EOL [\n]
SP [ \t]+
TITLESP [ \n\t]+
WORD [^ \n\t]+
WORDS {SP}*{WORD}{SP}*
XML {SP}*"<?xml"{SP}.*"?>"{SP}*{EOL}
DBLP {SP}*"<dblp>"{SP}*{EOL}
KEY {SP}*{WORD}"=\""{WORD}"\""{SP}*
ARTICLE {SP}*"<article"{SP}*{KEY}*{SP}*">"{SP}*{EOL}
AUTHOR {SP}*"<author>"{SP}*{WORDS}*{SP}*"</author>"{SP}*{EOL}
FINAUTHOR "</author>"{SP}*{EOL}
TITLE {SP}*"<title>"{TITLESP}*{WORDS}*{TITLESP}*"</title>"{SP}*{EOL}
PAGES {SP}*"<pages>"{SP}*{WORD}*{SP}*{EOL}
VOLUME {SP}*"<volume>"{SP}*[0-9]+{SP}*"</volume>"{SP}*{EOL}
JOURNAL {SP}*"<journal>"{SP}*{WORDS}+{SP}*"</journal>"{SP}*{EOL}
NUMBER {SP}*"<number>"{SP}*[0-9]+{SP}*"</number>"{SP}*{EOL}
YEAR {SP}*"<year>"{SP}*[0-9]+{SP}*"</year>"{SP}*{EOL}
EE {SP}*"<ee>"{SP}*{WORDS}*{SP}*"</ee>"{SP}*{EOL}
URL {SP}*"<url>".*"</url>"{SP}*{EOL}
CARTICLE {SP}*"</article>"{SP}*{EOL}
CDBLP {SP}*"</dblp>"{SP}*{EOL}
ERRLINE .*{EOL}

%%

{XML} { xml='1'; }
{DBLP} { if(xml) { dblp='1'; } else { fprintf(stderr, "Got dblp tag outside an xml section\n"); exit(0); } }
{ARTICLE} {
    if(dblp)
    {
        if(!article)
        {
            article='1'; 
            key = strdup(yytext);
        }
        else
        {
            fprintf(stderr, "Article tag found inside of another article section!\n");
        }
    }
    else
    {
        fprintf(stderr, "Article section not inside an dblp section\n"); 
        exit(0);
    }
}
{AUTHOR} { if(article) { authors[a++] = strdup(yytext); } else { fprintf(stderr, "Author found outside of article section\n"); } }
{TITLE} { if(article) { title = strdup(yytext); } else { fprintf(stderr, "Title found outside of article section\n"); }}
{PAGES} { if(article) { pages = strdup(yytext); } else { fprintf(stderr, "Title found outside of article section\n"); }} 
{VOLUME} { if(article) { volume = strdup(yytext); } else { fprintf(stderr, "Volume found outside of article section\n"); }}
{JOURNAL} { if(article) { journal = strdup(yytext); } else { fprintf(stderr, "Journal found outside of article section\n"); }}
{NUMBER} { if(article) { number = strdup(yytext); } else { fprintf(stderr, "Number found outside of article section\n"); }}
{YEAR} { if(article) { year = strdup(yytext); } else { fprintf(stderr, "Year found outside of article section\n"); }}
{EE} { if(article) { ee = strdup(yytext); } else { fprintf(stderr, "Ee found outside of article section\n"); }}
{URL} {}
{CARTICLE} { if(article) { printArticle(); resetVars(); article='\0';} }
{CDBLP} { if(dblp) { dblp='\0'; }}

{ERRLINE} { fprintf(stderr, "Unrecognized line: \"%s\"\n",yytext); }

%%

main()
{
    yylex();
}
