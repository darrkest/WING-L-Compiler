%{
#include <stdio.h>
extern FILE* yyin;
%}

%start prog_start
%token NUMBER ADD SUB MULT DIV L_PAREN R_PAREN EQUAL

%%

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
