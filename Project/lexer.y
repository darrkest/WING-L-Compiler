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

/*
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
*/

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
    	printf("Symbol: %s", symbol_table[i].name.c_str());
	std::string temp;
	if (symbol_table[i].type == 0) {
		temp = "Integer";
	}
	else if (symbol_table[i].type == 1) {
		temp = "Array";
	}
	else if (symbol_table[i].type == 2) {
		temp = "Function";
	}
     	printf(", type: %s\n", temp.c_str());
  }
  printf("--------------------\n");
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
%type <op_val> term
%type <node> prog_start
%type <node> functions 
%type <node> function
%type <node> arguments
%type <node> argument
%type <node> declared_term
%type <node> statements
%type <node> statement
%type <node> assignment
%type <node> write_call

%%

prog_start: %empty /* epsilon */ {}
	| functions { 
		// TODO: Fix seg fault, probably happening because of stuff further in the grammar
		printf("prog_start -> functions\n"); 
		//CodeNode *node = $1;
		//printf("%s\n", node->code.c_str());
	}

functions: %empty /* epsilon */ {}
	| function functions { 
		// TODO: Same as above
		printf("functions -> function functions\n"); 
		//CodeNode *node1 = $1;
		//CodeNode *node2 = $2;
		//CodeNode *node = new CodeNode();
		//node->code = node1->code + node2->code;
		//$$ = node;
	}

function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {
		// TODO: Fix seg fault, probably happening because of stuff further in the grammar
		//CodeNode *node = new CodeNode();
		//CodeNode *arguments = $4;
		//CodeNode *statements = $7;
	
		std::string func_name = $2;
		//node->code = "func " + func_name + arguments->code + statements->code;
		Type t = Function;
		temp_add_to_symbol_table(func_name,t);
		printf("funct %s\n", func_name.c_str());
		//$$ = node;
	}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {
		// TODO: Same as above
		//CodeNode *node = new CodeNode();
                //CodeNode *statements = $4;
		
		std::string func_name = $2;
                //node->code = "func " + func_name + statements->code;
		Type t = Function;
		temp_add_to_symbol_table(func_name,t);
		printf("funct %s\n", func_name.c_str());
		//$$ = node;
	}

arguments: argument {}			
	| argument COMMA arguments {
		// TODO: Fix seg fault, happens when parameters are in function
		//CodeNode *node1 = $1;
		//CodeNode *node2 = $3;
		//CodeNode *node = new CodeNode();
		//node->code = node1->code + node2->code;
		//$$ = node;
	}
	| %empty {	
		CodeNode *node = new CodeNode();
		$$ = node;
	}

argument: %empty /* epsilon */ {}
	| declared_term {}
	| term {}

declared_term: INTEGER IDENTIFIER {	
		CodeNode *node = new CodeNode();
		std::string var_name = $2;
		node->code = ". " + var_name + "\n";
		Type t = Integer;
		temp_add_to_symbol_table(var_name, t);
		//printf("variable %s\n", var_name.c_str());
		$$ = node;

		printf(". %s\n", var_name.c_str());
	}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {
		CodeNode *node = new CodeNode;	
		std::string var_name = $2;
		std::string arrNum = $4;
		node->code = ".[] " + var_name + ", " + arrNum; 
		Type t = Array;
		temp_add_to_symbol_table(var_name, t);
		//printf("array %s\n", var_name.c_str());
		$$ = node;

		printf(".[] %s, %s", var_name.c_str(), arrNum.c_str());
	}

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

assignment: IDENTIFIER EQUAL term SMCOL{
		std::string ident = $1;
		std::string assigned = $3;
		CodeNode *node = new CodeNode();
		node->code = "= " + ident + ", " + assigned + "\n";
		$$ = node;
		
		printf("= %s, %s\n", ident.c_str(), assigned.c_str());
	}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL term SMCOL {}

read_call: READ L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL {}
	| READ L_PAR IDENTIFIER R_PAR SMCOL {}

write_call: WRITE L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL {
		// This should output a temp because of array
		printf("write_call -> WRITE L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL\n");
                std::string ident = $3;
                std::string arrNum = $5;
		CodeNode *node = new CodeNode();
                node->code = ".> " + ident + "\n";
                $$ = node;
	}
	| WRITE L_PAR IDENTIFIER R_PAR SMCOL {
		//printf("write_call -> WRITE L_PAR IDENTIFIER R_PAR SMCOL\n");
		std::string ident = $3;

		CodeNode *node = new CodeNode();
		node->code = ".> " + ident + "\n";
		$$ = node;  

		printf(".> %s\n", ident.c_str());
	}

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
	| term PLUS term {}
	| term MINUS term {}
	| term DIV term {}
	| term MULT term {}
	| term MOD term {}

term: %empty /*epsilon*/ {}
	| IDENTIFIER { 
		//printf("term -> IDENTIFIER\n");
		$$ = $1; 
	}
	| IDENTIFIER L_SQUARE term R_SQUARE {
		$$ = $1;
	}
	| NUMBER {
		//printf("term -> NUMBER\n");
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
