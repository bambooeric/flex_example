FLEX=flex
CC=gcc
CFLAGS=-g
LIBS=-lfl
EXE=practica3

all:
	$(FLEX) $(EXE).l 
	$(CC) $(CFLAGS) -o $(EXE) lex.yy.c $(LIBS)
	
run:	all
	./$(EXE) < ejemplo.c

clean:
	rm $(EXE) lex.yy.c
