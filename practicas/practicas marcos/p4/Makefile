FLEX=flex
CC=gcc
CFLAGS=-g
LIBS=-lfl
EXE=practica4

all:
	$(FLEX) $(EXE).l 
	$(CC) $(CFLAGS) -o $(EXE) lex.yy.c $(LIBS)
	
run:	all
	./$(EXE) < ejemplo.txt

clean:
	rm $(EXE) lex.yy.c
