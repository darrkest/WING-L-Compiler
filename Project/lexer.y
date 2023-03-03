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
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%union {
	char *op_val;
}
%define parse.error verbose
%start prog_start
%token INTEGER CHAR FUNCTION RETURN COMMA SMCOL
%token PLUS MINUS MULT DIV MOD 
%token L_PAR R_PAR L_CURL R_CURL L_SQUARE R_SQUARE 
%token EQUAL
%token LESSER GREATER EQUALTO NOT NOTEQUAL AND OR
%token IFBR ELIFBR ELSEBR WLOOP 
%token READ WRITE
%token <op_val> NUMBER
%token <op_val> IDENTIFIER
%type <op_val> term

%%

prog_start: %empty /* epsilon */ {}
	| functions { printf("prog_start -> functions\n"); }

functions: %empty /* epsilon */ { printf("functions -> epsilon\n"); }
	| function functions { printf("functions -> function functions\n"); }

function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {
		std::string func_name = $2;
		add_function_to_symbol_table(func_name);
		printf("funct %s\n", func_name.c_str());
	}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {
		std::string func_name = $2;
		add_function_to_symbol_table(func_name);
		printf("funct %s\n", func_name.c_str());
	}

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
	
declaration: declared_term SMCOL{}

function_call: IDENTIFIER L_PAR arguments R_PAR {}

assignment: IDENTIFIER EQUAL term SMCOL{}
	| IDENTIFIER array EQUAL term SMCOL {}

read_call: READ L_PAR IDENTIFIER R_PAR SMCOL {}

write_call: WRITE L_PAR IDENTIFIER R_PAR SMCOL {}
	| WRITE L_PAR IDENTIFIER array R_PAR SMCOL {}

return_call: RETURN term SMCOL {}

while_call: WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL {}

if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call else_call {}

elif_call: %empty /*epsilon*/ {}
	| ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call {}

else_call: %empty /*epsilon*/ {}
	| ELSEBR L_CURL statements R_CURL {}

comparison: term comp term {}

comp: LESSER {}
	| GREATER {}
	| EQUALTO {}

operation: L_PAR operation R_PAR {}
	| term op term {}

op: PLUS {}
	| MINUS {}
	| MULT {}
	| DIV {}
	| MOD {}

declared_term: INTEGER IDENTIFIER array {}

array: %empty /*epsilon*/ {}
	| L_SQUARE term R_SQUARE {}

term: %empty /*epsilon*/ {}
	| IDENTIFIER array { 
		printf("term -> IDENTIFIER\n");
		$$ = $1; 
	}
	| NUMBER {
		printf("term -> NUMBER\n");
		$$ = $1;
	}
	| function_call{}
	| operation{}

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
