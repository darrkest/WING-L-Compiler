all: project
y.tab.c y.tab.h: lexer.y
	bison -v -d --file-prefix=y lexer.y
lex.yy.c: lexer.lex y.tab.h
	flex lexer.lex
project: lex.yy.c y.tab.c y.tab.h
	g++ -o parser y.tab.c lex.yy.c -lfl
clean:
	rm parser y.tab.c lex.yy.c y.tab.h y.output
