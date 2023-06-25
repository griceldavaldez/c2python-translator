all: program

program: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o programa

lex.yy.c: lex.l
	flex lex.l

y.tab.c: yacc.y
	bison -yd yacc.y

clean:
	rm -f lex.yy.c y.tab.c y.tab.h programa *.py