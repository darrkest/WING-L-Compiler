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
<<<<<<< HEAD
<<<<<<< HEAD
=======
%type <op_val> term
%type <op_val> operation
%type <op_val> multiplicative_operation
%type <node> return_call
%type <node> assignment
>>>>>>> main
=======

>>>>>>> main
%type <node> prog_start
%type <node> functions
%type <node> function
%type <node> arguments
%type <node> argument
%type <node> statements
%type <node> statement
<<<<<<< HEAD
%type <node> term
=======
%type <node> declaration
%type <node> declared_term
%type <node> write_call
%type <node> assignment
%type <node> operation
%type <node> multiplicative_operation
%type <node> term

>>>>>>> main
%%

prog_start: %empty /* epsilon */ {}
	| functions {
		CodeNode *node = $1;
		printf("%s\n", node->code.c_str());
	}

functions: %empty /* epsilon */ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| function functions {
		CodeNode *node = new CodeNode();
		CodeNode *func = $1;
		CodeNode *funcs = $2;
		node->code += func->code + funcs->code;
		$$ = node;
	}

function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {
		// Add to symbol table
                std::string func_name = $2;
                Type t = Function;
                temp_add_to_symbol_table(func_name,t);
		
<<<<<<< HEAD
	}	
	  L_PAR arguments R_PAR L_CURL statements R_CURL {
		
=======
		// Add the "func func_name"
                CodeNode *node = new CodeNode();
                node->code = "func " + func_name + "\n";
		// Add the arguments code
		CodeNode *args = $4;
		node->code += args->code;
		// Add the statements code
		CodeNode *states = $7;
		node->code += states->code;

		node->code += "endfunc\n";
		//node->code = "";
		$$ = node;
>>>>>>> main
	}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {
		// Add to symbol table
                std::string func_name = $2;
                Type t = Function;
                temp_add_to_symbol_table(func_name,t);
<<<<<<< HEAD
        
	}
	  L_CURL statements R_CURL {
		
	}

arguments: argument {}			
	| argument COMMA arguments {}
	| %empty {}
=======

                CodeNode *node = new CodeNode();
                node->code = "func " + func_name + "\n";
		
		CodeNode *states = $4;
		node->code += states->code;
		node->code += "endfunc\n";
		$$ = node;
	}

arguments: argument {
		CodeNode *node = $1;
		$$ = node;
	}			
	| argument COMMA arguments {
		CodeNode *node = new CodeNode();
		CodeNode *arg = $1;
		CodeNode *args = $3;
		node->code = arg->code + args->code;
		$$ = node;
	}
	| %empty {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
>>>>>>> main

argument: %empty /* epsilon */ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| declared_term {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| term {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| operation {}

<<<<<<< HEAD
declared_term: INTEGER IDENTIFIER {}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {}

statements: %empty /* epsilon */ {}
	| statement statements {}
=======
declared_term: INTEGER IDENTIFIER {	
		// Add to symbol table
		std::string var_name = $2;
		Type t = Integer;
		temp_add_to_symbol_table(var_name, t);

		CodeNode *node = new CodeNode();
		node->code = ". " + var_name + "\n";
		$$ = node;
	}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {
		// Add to symbol table
		std::string var_name = $2;
		Type t = Array;
		temp_add_to_symbol_table(var_name, t);
	}

statements: %empty /* epsilon */ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| statement statements {
		CodeNode *node = new CodeNode();
		CodeNode *state = $1;
		CodeNode *states = $2;
		node->code = state->code + states->code;
		$$ = node;
	}
>>>>>>> main

statement: declaration {
		CodeNode *node = $1;
		$$ = node;
	}
        | function_call {}
	| assignment {
		CodeNode *node = $1;
		$$ = node;
	}
	| read_call   {}
	| write_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| return_call {}
	| while_call {}
	| if_call {}
	| elif_call {}
	| else_call {}
	
<<<<<<< HEAD
declaration: declared_term SMCOL {}
=======
declaration: declared_term SMCOL{
		CodeNode *node = $1;
		$$ = node;
	}
>>>>>>> main

function_call: IDENTIFIER L_PAR arguments R_PAR {}

<<<<<<< HEAD
assignment: IDENTIFIER EQUAL operation SMCOL{}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL operation SMCOL {}

read_call: READ L_PAR term R_PAR SMCOL {}

write_call: WRITE L_PAR term R_PAR SMCOL {}

return_call: RETURN operation SMCOL {}
=======
assignment: IDENTIFIER EQUAL operation SMCOL{
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		CodeNode *rhs = $3;
		node->code = "= " + ident + ", " + rhs->code + "\n";
		$$ = node;
	}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL operation SMCOL {}

read_call: READ L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL {}
	| READ L_PAR IDENTIFIER R_PAR SMCOL {}

write_call: WRITE L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL {
		CodeNode *node = new CodeNode();
		std::string ident = $3;
		CodeNode *arr = $5;
		node->code = ".[]> " + ident + arr->code + "\n";
		$$ = node;
	}
	| WRITE L_PAR IDENTIFIER R_PAR SMCOL {
		CodeNode *node = new CodeNode();
		std::string ident = $3;
		node->code = ".> " + ident + "\n";
		$$ = node; 
	}
>>>>>>> main

return_call: RETURN term SMCOL {}
	| RETURN operation SMCOL {}	
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
<<<<<<< HEAD
<<<<<<< HEAD
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
=======
	| multiplicative_operation PLUS multiplicative_operation {
		CodeNode *node = new CodeNode();
		std::string temp = make_temp();
		std::string lhs = $1;
		std::string rhs = $3;
		node->code = ". " + temp + "\n";
		printf(". %s\n", temp.c_str());
		node->code = "+ " + temp + ", " + lhs + ", " + rhs + "\n";

		printf("+ %s, %s, %s\n", temp.c_str(), lhs.c_str(), rhs.c_str());
	}
	| multiplicative_operation MINUS multiplicative_operation {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                std::string lhs = $1;
                std::string rhs = $3;
                node->code = ". " + temp + "\n";
                printf(". %s\n", temp.c_str());
                node->code = "- " + temp + ", " + lhs + ", " + rhs + "\n";
                printf("- %s, %s, %s\n", temp.c_str(), lhs.c_str(), rhs.c_str());
	}
=======
	| multiplicative_operation PLUS multiplicative_operation {}
	| multiplicative_operation MINUS multiplicative_operation {}
>>>>>>> main
	| multiplicative_operation {
		CodeNode *node = $1;
		$$ = node;
	}

multiplicative_operation: term {
		CodeNode *node = $1;
		$$ = node;
	}
	| term MULT term {}
	| term DIV term {}
	| term MOD term {}

term: %empty /*epsilon*/ {}
	| IDENTIFIER {
		CodeNode *node = new CodeNode();
		node->code = $1;
		$$ = node;
	}
	| IDENTIFIER L_SQUARE term R_SQUARE {
<<<<<<< HEAD
		$$ = $1;
>>>>>>> main
=======
		CodeNode *node = new CodeNode();
		node->code = $1;
		$$ = node;
>>>>>>> main
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
