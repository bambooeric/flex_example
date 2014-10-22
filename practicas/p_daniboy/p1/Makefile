FUENTE = p1
EXE = analizador

compile: p1.l
	flex $(FUENTE).l
	gcc -o $(EXE) lex.yy.c -ll

clean:
	rm $(EXE) lex.yy.c
	
