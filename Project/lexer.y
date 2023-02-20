%{
#include <stdio.h>
extern FILE* yyin;

int yyerror(char *error){
        printf("Error.%s\n", error);
}
%}

%start prog_start
%token INTEGER IDENTIFIER NUMBER CHAR PLUS MINUS MULT DIV L_PAR R_PAR EQUAL LESSER GREATER EQUALTO NOT NOTEQUAL IFBR ELIFBR ELSEBR AND OR WLOOP READ WRITE FUNCTION L_CURL R_CURL L_SQUARE R_SQUARE COMMA RETURN

%%
prog_start: %empty /* epsilon */ {printf("prog_start->epsilon\n");}
	| functions {printf("prog_start -> functions\n");}

functions: function {printf("functions -> function\n");}
	| function functions {printf("functions -> function functions\n");}

function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {printf("function -> FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL\n");}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {printf("function -> FUNCTION IDENTIFIER L_CURL statements R_CURL\n");}

arguments: argument {printf("arguments -> argument\n");}
	| argument COMMA arguments {printf("arguments -> COMMA arguments\n");}

argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
	| INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
        | INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE {printf("argument -> INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE\n");}
	| term {printf("argument -> term\n");}

statements: %empty /* epsilon */ {printf("statements -> epsilon\n");}
	| statement statements {printf("statements -> statement statements\n");}

statement: declaration {printf("statement -> declaration\n");}
        | function_call {printf("statement -> function_call\n");}
	| assignment {printf("statement -> assignment\n");}
	| read_call   {printf("statement -> read_call\n");}
	| write_call {printf("statement -> write_call\n");}
	| return_call {printf("statement -> return_call\n");}
	| while_call {printf("statement -> while_call\n");}
	| if_call {printf("statement -> if_call\n");}
	| elif_call {printf("statement -> elif_call\n");}
	| else_call {printf("statement -> else_call\n");}
	
declaration: INTEGER IDENTIFIER {printf("declaration -> INTEGER IDENTIFIER\n");}

function_call: IDENTIFIER L_PAR arguments R_PAR {printf("function_call -> IDENTIFIER L_PAR arguments R_PAR\n");}
	| IDENTIFIER L_PAR operation R_PAR { printf("function_call -> IDENTIFIER L_PAR operation R_PAR\n");}

assignment: IDENTIFIER EQUAL NUMBER {printf("assignment -> IDENTIFIER EQUAL NUMBER\n");}
	| IDENTIFIER EQUAL IDENTIFIER {printf("assignment -> IDENTIFIER EQUAL IDENTIFIER\n");}
	| IDENTIFIER EQUAL operation {printf("assignment -> IDENTIFIER EQUAL operation\n");}
	| IDENTIFIER EQUAL function_call{printf("assignment -> IDENTIFIER EQUAL function_call\n");}

read_call: READ L_PAR IDENTIFIER R_PAR {printf("read_call -> READ L_PAR IDENTIFIER R_PAR\n");}

write_call: WRITE L_PAR IDENTIFIER R_PAR {printf("write_call -> WRITE L_PAR IDENTIFIER R_PAR\n");}

return_call: RETURN IDENTIFIER {printf("return_call -> RETURN IDENTIFIER\n");}
	| RETURN NUMBER { printf("return_call -> RETURN NUMBER\n");}
	| RETURN operation { printf("return_call -> RETURN operation\n");}

while_call: WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL { printf("while_call -> WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL\n");}

if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL {printf("if_call -> IFBR L_PAR comparison R_PAR L_CURL statements R_CURL\n");}

elif_call: ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL {printf("elif_call -> ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL\n");}

else_call: ELSEBR L_CURL statements R_CURL {printf("else_call -> ELSEIF L_CURL statements R_CURL\n");}

comparison: IDENTIFIER LESSER IDENTIFIER { printf("comparison -> IDENTIFIER LESSER IDENTIFIER\n");}
	| IDENTIFIER LESSER NUMBER { printf("comparison -> IDENTIFIER LESSER NUMBER\n");}
	| IDENTIFIER GREATER IDENTIFIER { printf("comparison -> IDENTIFIER GREATER IDENTIFIER\n");}
	| IDENTIFIER GREATER NUMBER { printf("comparison -> IDENTIFIER GREATER NUMBER\n");}
	| IDENTIFIER EQUALTO TERM {printf("comparison -> IDENTIFIER EQUAL TERM\n");}

operation: term addop term { printf("operation -> term addop term\n");}
	| term mulop term { printf("operation -> term mulop term\n");}

term: %empty /*epsilon*/ {printf("term -> epsilon\n");}
	| IDENTIFIER {printf("term -> IDENTIFIER\n");}
	| NUMBER {printf("term -> NUMBER\n");}
	| function_call{printf("term -> function_call\n");}

addop: PLUS { printf("addop -> PLUS\n");}
	| MINUS {printf("addop -> MINUS\n");}

mulop: MULT { printf("mulop -> MULT\n");}
	| DIV { printf("mulop -> DIV\n");}

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
