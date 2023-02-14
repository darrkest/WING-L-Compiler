%{
#include <stdio.h>
extern FILE* yyin;

int yyerror(char *error){
        printf("Error.%s\n", error);
}
%}

%start prog_start
%token INTEGER IDENTIFIER NUMBER CHAR PLUS MINUS MULT DIV L_PAR R_PAR EQUAL LESSER GREATER EQUALTO NOT NOTEQUAL IFBR ELIFBR ELSEBR AND OR WLOOP READ WRITE FUNCTION L_CURL R_CURL L_SQUARE R_SQUARE

%%
prog_start: %empty /* epsilon */ {printf("prog_start->epsilon\n");}
	| functions {printf("prog_start -> functions\n");}
	;

functions: function {printf("functions -> function\n");}
	| function functions {printf("functions -> function functions\n");}
	;

function: INTEGER IDENTIFIER LPAREN arguments RPAREN LBRACKET statements RBRACKET {printf("function -> INTEGER IDENTIFIER LPAREN arguments RPAREN LBRACKET statements RBRACKET\n");}
	;

arguments: argument {printf("arguments -> argument\n");}
	| argument COMMA arguments {printf("arguments -> COMMA arguments\n");}
	;

argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
	| INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
        | INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE {printf("argument -> INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE\n");}
	;

%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n");
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
