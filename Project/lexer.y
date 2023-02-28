%{
#include<string>
#include<vector>
#include<string.h>
#include <stdio.h>

extern int yylex(void);
void yyerror(const char *msg);
extern int errorLine;

char *identToken;
int numberToken;
int count_names = 0;

enum Type { Integer, Array };
struct Symbol {
	std::string name;
	Type type;
};
struct Function {
	std::string name;
	std::vector<Symbol> declarations;
};

std::vector<Function> symbol_table;

Function *get_function() {
	int last = symbol_table.size()-1;
	return &symbol_table[last];
}

bool find(std::string &value) {
	Function *f = get_function();
	for(int i = 0; i < f->declarations.size(); ++i) {
		Symbol *s = &f->declarations[i];
		if (s->name == value) {
			return true;
		}
	}
	return false;
}

void add_function_to_symbol_table(std::string &value) {
	Function f;
	f.name = value;
	symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
	Symbol s;
	s.name = value;
	s.type = t;
	Function *f = get_function();
	f->declarations.push_back(s);
}

void print_symbol_table(void) {
}

%}

%union {
	char *op_val;
}
%define parse.error verbose
%start prog_start
%token INTEGER CHAR PLUS MINUS MULT DIV MOD L_PAR R_PAR ASSIGN EQUAL LESSER GREATER EQUALTO NOT NOTEQUAL IFBR ELIFBR ELSEBR AND OR WLOOP READ WRITE FUNCTION L_CURL R_CURL L_SQUARE R_SQUARE COMMA RETURN
%token <op_val> NUMBER
%token <op_val> IDENTIFIER
%type <op_val> term

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
  yyparse();
  print_symbol_table();
  return 0;
}

void yyerror(const char *msg) {
	printf("** Line %d: %s\n", errorLine, msg);
	exit(1);
}
