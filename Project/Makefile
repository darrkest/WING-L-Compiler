all: project
y.tab.c y.tab.h: bison.y
	bison -v -d --file-prefix=y bison.y
lex.yy.c: lexer.lex y.tab.h
	flex lexer.lex
project: lex.yy.c y.tab.c y.tab.h
	g++ -o wing_compiler y.tab.c lex.yy.c -lfl
clean:
	rm wing_compiler y.tab.c lex.yy.c y.tab.h y.output
