/* Autor: Marcos López Lorenzo */
#include <stdio.h>
#include <string.h>

#define END_PROCESS     {                               \
    fprintf(stderr, "Unrecognized Symbol %c [S: %d | C: %d]\n", c, state, col);     \
    state = 0;                                          \
    i = 0; d = 0; h = 0;                                \
}

int valor[]   = {1, 2, 6, 3, 8, 7, 6, 4, 4, 4, 5, 4, 6, 8, 7, 9, 9, 10};
int columna[] = {0, 1, 0, 2, 3, 4, 0, 0, 5, 0, 4, 5, 0, 3, 4, 0, 0,  4};

int PreFil[] = {0, 2, 6, 7, 9, 0, 12, 0, 15, 16, 0};
int NumFil[] = {2, 4, 1, 2, 3, 0,  3, 0,  1,  2, 0};

int alg(int i, int j)
{
   int num, com, k;
   char hallado;

   num = NumFil[i];
   if (!num)
      return 999;
   else
   {
      com = PreFil[i];
      hallado = 0;
      k = 0;
      while((k < num) && (!hallado))
         if (columna[com+k] == j)
            hallado = 1;
         else
            ++k;
      if (hallado)
         return valor[com+k];
      else
         return 999;
   }
}

int num(char c)
{
    if( (c >= 48) && (c <= 57) )
        return 1;
    return 0;
}

int sign(char c)
{
    if ( (c == '-') || (c == '+') )
        return 1;
    return 0;
}

int x(char c)
{
    if (c == 'x')
        return 1;
    return 0;
}

int dot(char c)
{
    if (c == '.')
        return 1;
    return 0;
}

int end(char c)
{
    if (c == '$')
        return 1;
    return 0;
}

int letter(char c)
{
    if( ((c >= 97) && (c<=102)) || ((c >= 65) && (c <= 70)) )
        return 1;
    return 0;
}

void printHex(char hex[20], int h)
{
    int i=0;
    printf("It's an Hex number: ");
    while(i<h)
        printf("%c",hex[i++]);
    printf("\n");
}

void printInt(char integer[20], int i, char decimal[20], int d)
{
    int j=0;
    int k=0;
    printf("It's a decimal number: ");
    while(j<i)
        printf("%c",integer[j++]);
    if(d)
        printf(".");
    while(k<d)
        printf("%c",decimal[k++]);
    printf("\n");
}

int main(int argc, char *argv[])
{
    int j=0;
    int k=1;
    int state;
    int col;
    int size;
    char *string;
    char c;
    char integer[20];
    int i=0;
    char decimal[20];
    int d=0;
    char hex[20];
    int h=0;

    while(k<argc)
    {
        string = argv[k++];
        size = strlen(string);
        state = 0;
        i=0;
        d=0;
        h=0;
        j=0;
        while(j<=size)
        {
            c = string[j++];


            if (num(c))
                col = 0;  /* It's a number */
            else if (sign(c))
                col = 1;  /* It's a +/- sign */
            else if(x(c))
                col = 2;  /* It's an 'x' */
            else if(dot(c))
                col = 3;  /* It's a '.' */
            else if(end(c))
                col = 4;  /* It's a '$', signaling end of word */
            else if(letter(c))
                col = 5;  /* It's an hexadecimal letter */

            switch(state)
            {
                case 0:
                    switch (col)
                    {
                        case 0:
                            if(c ==  '0')
                                hex[h++] = c;
                            integer[i++] = c;
                            state = alg(state,col);
                            break;
                        case 1:
                            integer[i++] = c;
                            state = alg(state,col);
                            break;
                        default:
                            END_PROCESS;
                            break;
                    }
                    break;
                case 1:
                    switch (col)
                    {
                        case 0:
                            integer[i++] = c;
                            state = alg(state, col);
                            break;
                        case 2:
                            if (h)
                            {
                                hex[h++] = c;
                                state = alg(state, col);
                            }
                            else
                                END_PROCESS;
                            break;
                        case 3:
                            state = alg(state, col);
                            break;
                        case 4:
                            state = alg(state, col);
                            break;
                        default:
                            END_PROCESS;
                            break;
                    }
                    break;
                case 2:
                    if(col == 0)
                    {
                        integer[i++] = c;
                        state = alg(state,col);
                    }
                    else
                        END_PROCESS;
                    break;
                case 3:
                    if(((col == 0) || (col == 5)) && h)
                    {
                        hex[h++] = c;
                        state = alg(state,col);
                    }
                    else
                        END_PROCESS;
                    break;
                case 4:
                    switch (col)
                    {
                        case 0:
                        case 5:
                            hex[h++] = c;
                            state = alg(state, col);
                            break;
                        case 4:
                            state = alg(state, col);
                            break;
                        default:
                            END_PROCESS;
                            break;
                    }
                    break;
                case 5:
                    printHex(hex, h);
                    state = 0;
                    break;
                case 6:
                    switch(col)
                    {
                        case 0:
                            integer[i++] = c;
                            state = alg(state,col);
                            break;
                        case 3:
                            state = alg(state,col);
                            break;
                        case 4:
                            state = alg(state,col);
                            break;
                        default:
                            END_PROCESS;
                    }
                    break;
                case 7:
                    printInt(integer, i, decimal, d);
                    state = 0;
                    break;
                case 8:
                    if(col == 0)
                    {
                        decimal[d++] = c;
                        state = alg(state,col);
                    }
                    else
                        END_PROCESS;
                    break;
                case 9:
                    if(col == 0)
                    {
                        decimal[d++] = c;
                        state = alg(state,col);
                    }
                    else if(col == 4)
                        state = alg(state,col);
                    else
                        END_PROCESS;
                    break;
                case 10:
                    printInt(integer, i, decimal, d);
                    state = 0;
                    break;
                default:
                    END_PROCESS;
            }
        }

    }
    return 0;
}
