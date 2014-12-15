FUENTE = mips2c
PRUEBA = test.mips
PRUEBA2 = test2.mips
PRUEBA3 = test3.mips

all: compile run

compile:
	flex $(FUENTE).l
	bison  -o $(FUENTE).tab.c $(FUENTE).y -yd --verbose -Wconflicts-sr
	gcc -g -o $(FUENTE) lex.yy.c $(FUENTE).tab.c -lfl -ly 

run:
	./$(FUENTE) < $(PRUEBA3)

clean:
	rm $(FUENTE) lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h *out $(FUENTE).output output.c

