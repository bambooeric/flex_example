%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BADDNI 0
#define BADDNIMSG "DNI incorrecto\n"
#define BADGROUP 1
#define BADGROUPMSG "Grupo incorrecto\n"
#define BADSCOREA 2
#define BADSCOREAMSG "Nota1 incorrecta\n"
#define BADSCOREB 3
#define BADSCOREBMSG "Nota2 incorrecta\n"
#define UNKNOWN 4
#define UNKNOWNMSG "Error sin identificar\n"

char *header = NULL;
char **lines;
int l = 0;
int good[255];
int g=0;
int bad[255];
int b=0;
int type[255];


%}
EOL [\n]
WORD [^ \n\t]+
DNI [0-9]{8}\-{1}[A-Z]{1}[ ]
GROUP [1-9]{1}[A-Z]{1}
SCORE [0-9]{1}\.[0-9]{1,2}|10\.{0,1}[0]{0,2}
HEADER .*\-.*\/.*{EOL}
LINE {DNI}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{GROUP}[ \t]*{SCORE}[ \t]*{SCORE}[ \t]*{EOL}
BADDNI {WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{GROUP}[ \t]*{SCORE}[ \t]*{SCORE}[ \t]*{EOL}
BADGROUP {DNI}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{SCORE}[ \t]*{SCORE}[ \t]*{EOL}
BADSCORE1 {DNI}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{GROUP}[ \t]*{WORD}[ \t]*{SCORE}[ \t]*{EOL}
BADSCORE2 {DNI}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{WORD}[ \t]*{GROUP}[ \t]*{SCORE}[ \t]*{WORD}[ \t]*{EOL}
ERROR .*\n
%%
{HEADER}        { header = strdup(yytext); ++l;}
{LINE}          { lines[l] = strdup(yytext); good[g++] = l++;}
{BADDNI}        { bad[b] = l++; type[b++] = BADDNI;}
{BADGROUP}        { bad[b] = l++; type[b++] = BADGROUP;}
{BADSCORE1}        { bad[b] = l++; type[b++] = BADSCOREA;}
{BADSCORE2}        { bad[b] = l++; type[b++] = BADSCOREB;}
{ERROR}         { bad[b] = l++; type[b++] = UNKNOWN;}
%%
main()
{
    float score=0.00, numscore=0.00;
    char *line;
    char *string;
    char *dni, *mname, *lname, *name, *group, *score1, *score2;
    int i;

    lines = malloc(255*sizeof(char*));
    yylex();
    printf("Lines: %d, %d good %d bad\n",l,g,b);
    if(!header)
    {
        printf("No Header Found!!\n");
        exit(0);
    }
    printf("%s\n",header);
    string = strtok(header,"-");
    printf("Asignatura: %s\n",string);
    string = strtok(NULL," ");
    string = strtok(NULL," ");
    printf("Curso: %s\n",string);
    printf("Alumnos suspensos:\n");
    for (i=0;i<g;++i)
    {
        line = strdup(lines[good[i]]);
        dni = strtok(line," ");
        mname = strtok(NULL," ");
        lname = strtok(NULL," ");
        name = strtok(NULL," ");
        group = strtok(NULL," ");
        score1 = strtok(NULL," ");
        score2 = strtok(NULL," ");
        if((atof(score1) < 5.00) || (atof(score2) < 5.00))
            printf("%s;%s %s %s\n",dni,mname,lname,name);
        free(line);
    }
    printf("Alumnos aprobados:\n");
    for (i=0;i<g;++i)
    {
        line = strdup(lines[good[i]]);
        dni = strtok(line," ");
        mname = strtok(NULL," ");
        lname = strtok(NULL," ");
        name = strtok(NULL," ");
        group = strtok(NULL," ");
        score1 = strtok(NULL," ");
        score2 = strtok(NULL," ");
        if((atof(score1) >= 5.00) && (atof(score2) >= 5.00))
            printf("%s;%s %s %s;%2.2f\n",dni,mname,lname,name,(atof(score1)+atof(score2))/2);
        free(line);
    }
    printf("Errores:\n");
    for (i=1;i<b;++i)
    {
        printf("Linea %d:",bad[i]+1);
        switch(type[i])
        {
            case 0:
                printf(BADDNIMSG);
                break;
            case 1:
                printf(BADGROUPMSG);
                break;
            case 2:
                printf(BADSCOREAMSG);
                break;
            case 3:
                printf(BADSCOREBMSG);
                break;
            default:
                printf(UNKNOWNMSG);
                break;
        }
    } 

    return 0;
}
