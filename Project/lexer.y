%{
#include <stdio.h>
extern FILE* yyin;

int yyerror(char *error){
        printf("Error.%s\n", error);
}
%}

%start prog_start
%token INTEGER IDENTIFIER NUMBER CHAR PLUS MINUS MULT DIV L_PAR R_PAR EQUAL LESSER GREATER EQUALTO NOT NOTEQUAL IFBR ELIFBR ELSEBR AND OR WLOOP READ WRITE FUNCTION L_CURL R_CURL L_SQUARE R_SQUARE COMMA

%%
prog_start: %empty /* epsilon */ {printf("prog_start->epsilon\n");}
	| functions {printf("prog_start -> functions\n");}
	;

functions: function {printf("functions -> function\n");}
	| function functions {printf("functions -> function functions\n");}
	;

function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {printf("function -> FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL\n");}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {printf("function -> FUNCTION IDENTIFIER L_CURL statements R_CURL\n");}
	;

arguments: argument {printf("arguments -> argument\n");}
	| argument COMMA arguments {printf("arguments -> COMMA arguments\n");}
	;

argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
	| INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
        | INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE {printf("argument -> INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE\n");}
	;

statements: %empty /* epsilon */ {printf("statements -> epsilon\n");}
	;

statement: declaration {printf("statement -> declaration\n");}
        | function_call {printf("statement -> function_call\n");}
	
Declaration: INTEGER IDENTIFIER {printf("declaration -> INTEGER IDENTIFIER\n");}

function_call: IDENTIFIER L_PAR args R_PAR {printf("function_call -> IDENTIFIER L_PAR args R_PAR\n");}

args: %empty {printf("args -> epsilon\n");}
%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n");
  if (argc >= 2) {
	yyin = fopen(argv[1], "r");
	if (yyin == NULL) {
		yyin = stdin;
	}
  }
  else {
	yyin = stdin;
  }
  yyparse();
  return 1;
  printf("Quitting...\n");
}
