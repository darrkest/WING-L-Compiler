%{
#include <stdio.h>
extern FILE* yyin;
%}

%start prog_start
%token INT SMICOLON IDENT LBR RBR COMMA LPR RPR

%%
prog_start: /* epsilon */ {printf("prog_start -> epsilon\n");}
        | functions {printf("prog_start -> functions\n");}

functions: function {printf("functions -> function\n");}
        |  function functions {printf("functions -> function functions\n");}

function: INT IDENT LPR arguments RPR LBR statements RBR {printf("function -> INT IDENT LPR arguments RPR LBR statements RBR\n");}

arguments: argument {printf("arguments -> argument\n");}
        | argument COMMA arguments {printf("argumenits -> COMMA arguments\n");}

argument: /*epsilon*/ {printf("argument -> epsilon\n");}
        | INT IDENT {printf("argument -> INT IDENT\n");}

statements: /* epsilon */ {printf("statements -> epsilon\n");}
        | statement SMICOLON statements {printf("statemtents -> statement SMICOLON statements\n");}

statement: declaration {printf("statement -> declaration\n");}
        | function_call {printf("statement -> function_call\n");}

declaration: INT IDENT {printf("declaration -> INT IDENT\n");}

function_call: IDENT LPR args RPR {printf("function_call -> IDENT LPR args RPR\n");}

args: %empty {printf("args -> epsilon\n");}
%%

void main(int argc, char** argv) {
        if(argc >= 2) {
                yyin = fopen(argv[1], "r");
                if (yyin == NULL) {
                        yyin = stdin;
                }
        }else {
                yyin = stdin;
        }
        yyparse();
}
int yyerror() {}
