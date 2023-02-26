%{
#include<string>
#include<vector>
#include<string.h>
#include <stdio.h>

extern FILE* yyin;

struct CodeNode {
  std::string code;
  std::string name;
};

var: IDENTIFIER {
  CodeNode *node = new CodeNode;
  node->code = "";
  node->name = $1;
  std::string error;
  if (!find(node->name, Integer, error)) {
     yyerror(error.c_str());
  }
  $$ = node;
}

statement: IDENTIFIER ASSIGN IDENTIFIER PLUS IDENTIFIER {}
	| IDENTIFIER ASSIGN IDENTIFIER {
	  struct CodeNode *node = new CodeNode;
	  std::string identifier= $1;
	  std::string symbol = $3;
	  node->code = "= " + identifier + ", " + symbol + "\n";
	  $$ = node;
	}

int yyerror(char *error){
        printf("Error.%s\n", error);
}
%}

%start prog_start
%token INTEGER IDENTIFIER NUMBER CHAR PLUS MINUS MULT DIV L_PAR R_PAR EQUAL LESSER GREATER EQUALTO NOT NOTEQUAL IFBR ELIFBR ELSEBR AND OR WLOOP READ WRITE FUNCTION L_CURL R_CURL L_SQUARE R_SQUARE COMMA RETURN

%%
prog_start: %empty /* epsilon */ {}
	| functions {}

functions: function {}
	| function functions {}

function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {}

arguments: argument {}
	| argument COMMA arguments {}

argument: %empty /* epsilon */ {}
	| INTEGER IDENTIFIER {}
        | INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE {}
	| term {}

statements: %empty /* epsilon */ {}
	| statement statements {}

statement: declaration {}
        | function_call {}
	| assignment {}
	| read_call   {}
	| write_call {}
	| return_call {}
	| while_call {}
	| if_call {}
	| elif_call {}
	| else_call {}
	
declaration: INTEGER IDENTIFIER {}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {}

function_call: IDENTIFIER L_PAR arguments R_PAR {}
	| IDENTIFIER L_PAR operation R_PAR {}

assignment: IDENTIFIER EQUAL term {}
	| IDENTIFIER EQUAL operation {}

read_call: READ L_PAR IDENTIFIER R_PAR {}

write_call: WRITE L_PAR IDENTIFIER R_PAR {}

return_call: RETURN IDENTIFIER {}
	| RETURN NUMBER {}
	| RETURN operation {}

while_call: WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL {}

if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call else_call {}

elif_call: %empty /*epsilon*/ {}
	| ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call {}

else_call: %empty /*epsilon*/ {}
	| ELSEBR L_CURL statements R_CURL {}

comparison: term LESSER term {}
	| term GREATER term {}
	| term EQUALTO term {}

operation: term addop term {}
	| term mulop term {}

term: %empty /*epsilon*/ {}
	| IDENTIFIER {}
	| NUMBER {}
	| function_call{}

addop: PLUS {}
	| MINUS {}

mulop: MULT {}
	| DIV {}

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
