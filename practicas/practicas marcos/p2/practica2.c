/* Autor: Marcos López Lorenzo */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define END_PROCESS     {                               \
    fprintf(stderr, "Unrecognized Symbol %c [S: %d | C: %d]\n", c, state, d);     \
    state = 0;                                          \
    i = 0; d = 0; h = 0;                                \
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

int alg(int list[20], int size, char *str)
{
    int j=0;
    int state=0;
    char c;
    int s;
    char integer[20];
    int i=0;
    char decimal[20];
    int d=0;
    char hex[20];
    int h=0;

    while(j<=size)
    {
        c = str[j];
        s = list[j++];

        switch(state)
        {
            case 0:
                switch (s)
                {
                    case 0:
                        if(c ==  '0')
                            hex[h++] = c;
                        integer[i++] = c;
                        state = 1;
                        break;
                    case 1:
                        integer[i++] = c;
                        state = 2;
                        break;
                    default:
                        END_PROCESS;
                        break;
                }
                break;
            case 1:
                switch (s)
                {
                    case 0:
                        integer[i++] = c;
                        state = 6;
                        break;
                    case 2:
                        if (h)
                        {
                            hex[h++] = c;
                            state = 3;
                        }
                        else
                            END_PROCESS;
                        break;
                    case 3:
                        state = 8;
                        break;
                    case 4:
                        state = 7;
                        break;
                    default:
                        END_PROCESS;
                        break;
                }
                break;
            case 2:
                if(s == 0)
                {
                    integer[i++] = c;
                    state = 6;
                }
                else
                    END_PROCESS;
                break;
            case 3:
                if(((s == 0) || (s == 5)) && h)
                {
                    hex[h++] = c;
                    state = 4;
                }
                else
                    END_PROCESS;
                break;
            case 4:
                switch (s)
                {
                    case 0:
                    case 5:
                        hex[h++] = c;
                        state = 4;
                        break;
                    case 4:
                        state = 5;
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
                switch(s)
                {
                    case 0:
                        integer[i++] = c;
                        state = 6;
                        break;
                    case 3:
                        state = 8;
                        break;
                    case 4:
                        state = 7;
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
                if(s == 0)
                {
                    decimal[d++] = c;
                    state = 9;
                }
                else
                    END_PROCESS;
                break;
            case 9:
                if(s == 0)
                {
                    decimal[d++] = c;
                    state = 9;
                }
                else if(s == 4)
                    state = 10;
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



int main(int argc, char *argv[])
{
    int k=1;
    int i;
    char c;
    int size;
    char *string;
    int list[20];
    
    while(k<argc)
    {
        string = argv[k++];
        size = strlen(string);

        for(i=0;i<size;++i)
        {
            c = string[i];

            if (num(c))
                list[i] = 0;  /* It's a number */
            else if (sign(c))
                list[i] = 1;  /* It's a +/- sign */
            else if(x(c))
                list[i] = 2;  /* It's an 'x' */
            else if(dot(c))
                list[i] = 3;  /* It's a '.' */
            else if(end(c))
                list[i] = 4;  /* It's a '$', signaling end of word */
            else if(letter(c))
                list[i] = 5;  /* It's an hexadecimal letter */
        }
        
        alg(list, size, string);

    }
           
    return 0;
}
