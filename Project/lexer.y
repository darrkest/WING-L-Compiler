%{
#include<string>
#include<sstream>
#include<vector>
#include<string.h>
#include <stdio.h>

extern int yylex(void);
void yyerror(const char *msg);
extern int errorLine;

struct CodeNode{
        std::string code;
        std::string name;
};

char *identToken;
int numberToken;
int count_names = 0;

enum Type { Integer, Array, Function };
struct Symbol {
	std::string name;
	Type type;
};

std::vector<Symbol> symbol_table;

bool find(std::string &value) {
	Symbol s = symbol_table[symbol_table.size()-1];
	for (int i = 0; i < symbol_table.size(); ++i) {
		if (s.name == value) {
			return true;
		}
	}
}

void temp_add_to_symbol_table(std::string &value, Type t) {
	Symbol s;
	s.name = value;
	s.type = t;
	symbol_table.push_back(s);	
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
	std::string temp;
	if (symbol_table[i].type == 0) {
		printf("   locals (int): %s\n", symbol_table[i].name.c_str());
	}
	else if (symbol_table[i].type == 1) {
		printf("   locals (array): %s\n", symbol_table[i].name.c_str());
	}
	else if (symbol_table[i].type == 2) {
		printf("function: %s\n", symbol_table[i].name.c_str());
	}
  }
  printf("--------------------\n");
}

int global_variable_counter = 0;

std::string make_temp() {
	std::ostringstream os;
	os << "_temp" << global_variable_counter++;
	return os.str();
}

%}

%union {
	char *op_val;
	struct CodeNode* node;
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
%type <node> prog_start
%type <node> functions
%type <node> function
%type <node> arguments
%type <node> argument
%type <node> statements
%type <node> statement
%type <node> term
%%

prog_start: %empty /* epsilon */ {}
	| functions {}

functions: %empty /* epsilon */ {}
	| function functions {}

function: FUNCTION IDENTIFIER 
	{
		std::string func_name $2;
		Type t = Function;
                temp_add_to_symbol_table(func_name,t);
		
	}	
	  L_PAR arguments R_PAR L_CURL statements R_CURL {
		
	}
	| FUNCTION IDENTIFIER 
	{
		std::string func_name $2;
                Type t = Function;
                temp_add_to_symbol_table(func_name,t);
        
	}
	  L_CURL statements R_CURL {
		
	}

arguments: argument {}			
	| argument COMMA arguments {}
	| %empty {}

argument: %empty /* epsilon */ {}
	| declared_term {}
	| term {}

declared_term: INTEGER IDENTIFIER {}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {}

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
	
declaration: declared_term SMCOL {}

function_call: IDENTIFIER L_PAR arguments R_PAR {}

assignment: IDENTIFIER EQUAL operation SMCOL{}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL operation SMCOL {}

read_call: READ L_PAR term R_PAR SMCOL {}

write_call: WRITE L_PAR term R_PAR SMCOL {}

return_call: RETURN operation SMCOL {}

while_call: WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL {}

if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call else_call {}

elif_call: %empty /*epsilon*/ {}
	| ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call {}

else_call: %empty /*epsilon*/ {}
	| ELSEBR L_CURL statements R_CURL {}

comparison: operation comp operation {}

comp: LESSER {}
	| GREATER {}
	| EQUALTO {}

operation: L_PAR operation R_PAR {}
	| operation PLUS multiplicative_operation {}
	| operation MINUS multiplicative_operation {}
	| multiplicative_operation {}

multiplicative_operation: multiplicative_operation MULT term {}
	| multiplicative_operation DIV term {}
	| multiplicative_operation MOD term {}
	| term {}
term: %empty /*epsilon*/ {}
	| IDENTIFIER { 
		CodeNode *node = new CodeNode();
		node->name = $1;
		node->code = "";
		$$ = node; 
	}
	| IDENTIFIER L_SQUARE term R_SQUARE {
		CodeNode *node = new CodeNode();
		node->name = $1;
		node->code = "";
		$$ = node;
	}
	| NUMBER {
		CodeNode *node = new CodeNode();
		node->code = $1;
		$$ = node;
	}

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
