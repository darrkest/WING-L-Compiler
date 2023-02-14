all:
	flex lexer.lex
	bison -v -d --file-prefix=y lexer.y
	gcc -o parser lex.yy.c y.tab.c -lfl
clean:
	rm -f parser lex.yy.c y.tab.c
