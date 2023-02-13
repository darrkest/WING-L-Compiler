%{
#include <stdio.h>
extern FILE* yyin;
%}

%start prog_start
%token INT SMICOLON IDENT LBR RBR COMMA LPR RPR

%%

prog_start: /* epsilon */ {printf("prog_start -> epsilon\n");}
        | functions {printf("prog_start -> functions\n");}

functions: function {printf("functions -> functions\n");}
        | function functions {printf("functions -> function functions\n");}

function: INT IDENT LPR arguments RPR LBR statements RBR {printf("function -> INT IDENT LPR arguments RPR LBR statements RBR\n");}

argument: /* epsilon */ {printf("argument -> epsilon\n");}
        | argument COMMA arguments {printf("arguments -> COMMA arguments\n");}

argument: /* epsilon */ {printf("argument -> epsilon\n");}
        | INT IDENT {printf("argument -> INT IDENT\n");}

statement: /* epsilon */ {printf("statment -> epsilon\n");}
        | statement SMICOLON statements {printf("statements -> statement SMICOLON statements\n");}

statement: delcaration {printf("statment -> declaration\n");}
        | function_call {printf("statement -> functio_call\n");}

delcaration: INT IDENT {printf("delcaration -> INT IDENT\n");}

function_call: IDENT LPR args RPR {printf("function_call -> IDENT LPR args RPR\n");}

args: %empty {printf("args -> empty\n");}

%%

void main(int argc, char** argv) {
        if(argc >= 2) {
                yyin = fopen(argv[1], "r");
                if (yyin == NULL) {
                        yyin = stdin;
                }
        else {
                yyin = stdin;
        }
        yyparse();
}
int yyerror() {}
