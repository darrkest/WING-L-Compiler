all:
        flex calc2.lex
        bison -v -d --file-prefix=y calc2.y
        gcc -o parser lex.yy.c y.tab.c -lfl

clean:
        rm -f parser ledx.yy.c y.tab.c
