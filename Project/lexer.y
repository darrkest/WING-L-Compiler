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
	//printf("make_temp call\n");
	return os.str();
}

int arg_counter = -1;
std::vector<std::string> arg_list;

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
%type <node> declaration
%type <node> declared_term
%type <node> read_call
%type <node> write_call
%type <node> assignment
%type <node> operation
%type <node> multiplicative_operation
%type <node> term
%type <node> return_call
%type <node> function_call
%type <node> func_call_arguments
%type <node> func_call_argument
%type <node> if_call
%type <node> elif_call
%type <node> else_call
%type <node> comparison

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
		arg_counter = -1;
		$$ = node;
	}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {
		// Add to symbol table
                std::string func_name = $2;
                Type t = Function;
                temp_add_to_symbol_table(func_name,t);

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

argument: %empty /* epsilon */ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| INTEGER IDENTIFIER {
                ++arg_counter;
		char arg[100];
		sprintf(arg, "%d", arg_counter);

                // Add to symbol table
                std::string var_name = $2;
                Type t = Integer;
                temp_add_to_symbol_table(var_name, t);

                CodeNode *node = new CodeNode();
                node->name = var_name;

                node->code = ". " + var_name + "\n";
                node->code += "= " + var_name + ", " + "$" + arg + "\n";
                $$ = node;
        }
        | INTEGER IDENTIFIER L_SQUARE term R_SQUARE {
                // Add to symbol table
                std::string var_name = $2;
                CodeNode *arrSize = $4;
                Type t = Array;
                temp_add_to_symbol_table(var_name, t);

                CodeNode *node = new CodeNode();
                node->name = var_name;
                node->code = ".[] " + var_name + ", " + arrSize->name + "\n";
                $$ = node;
        }

declared_term: INTEGER IDENTIFIER {	
		// Add to symbol table
		std::string var_name = $2;
		Type t = Integer;
		temp_add_to_symbol_table(var_name, t);

		CodeNode *node = new CodeNode();
		node->name = var_name;

		node->code = ". " + var_name + "\n";
		$$ = node;
	}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {
		// Add to symbol table
		std::string var_name = $2;
		CodeNode *arrSize = $4;
		Type t = Array;
		temp_add_to_symbol_table(var_name, t);
		
		CodeNode *node = new CodeNode();
		node->name = var_name;
		node->code = ".[] " + var_name + ", " + arrSize->name + "\n";
		$$ = node;
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

statement: declaration {
		CodeNode *node = $1;
		$$ = node;
	}
        | function_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| assignment {
		CodeNode *node = $1;
		$$ = node;
	}
	| read_call   {
		CodeNode *node = $1;
		$$ = node;
	}
	| write_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| return_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| while_call {}
	| if_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| elif_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| else_call {
		CodeNode *node = $1;
		$$ = node;
	}
	
declaration: declared_term SMCOL{
		CodeNode *node = $1;
		$$ = node;
	}

function_call: IDENTIFIER L_PAR func_call_arguments R_PAR {
		CodeNode *node = new CodeNode();
		std::string func_name = $1;
		CodeNode *args = $3;
		
		std::string temp = make_temp();
		node->code = args->code;
		node->code += ". " + temp + "\n";
		node->name = temp;
		node->code += "call " + func_name + ", " + temp + "\n";

		$$ = node;
	}

func_call_arguments: func_call_argument {
                CodeNode *node = $1;
                $$ = node;
        }
        | func_call_argument COMMA func_call_arguments {
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


func_call_argument: %empty /* epsilon */ {
                CodeNode *node = new CodeNode();
                node->code = "";
                $$ = node;
        }
        | IDENTIFIER {
                CodeNode *node = new CodeNode();
                std::string var_name = $1;
		node->name = var_name;
                node->code = "param " + node->name + "\n";
                $$ = node;
        }
        | IDENTIFIER L_SQUARE term R_SQUARE {
                CodeNode *node = new CodeNode();
		std::string var_name = $1;
		CodeNode *arrSize = $3;
                node->name = var_name;
                node->code = ".[] " + var_name + ", " + arrSize->name + "\n";
                $$ = node;
        }
        | operation {
                // function call operation stuff goes here
                CodeNode *node = $1;
		node->code += "param " + node->name + "\n";
                $$ = node;
        }

assignment: IDENTIFIER EQUAL operation SMCOL{
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		CodeNode *rhs = $3;
		node->code += rhs->code;
		node->code += "= " + ident + ", " + rhs->name + "\n";
		$$ = node;
	}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL operation SMCOL {
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		CodeNode *index = $3;
		CodeNode *rhs = $6;
		node->code += rhs->code;
		node->code += "[]= " + ident + ", " + index->name + ", " + rhs->name + "\n";
		$$ = node;
	}

read_call: READ L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                std::string ident = $3;
                CodeNode *arr = $5;
                node->code = ". " + temp + "\n";
                node->code += "=[] " + temp + ", " + ident + ", " + arr->name + "\n";
                node->code += ".< " + temp + "\n";
                $$ = node;
	}
	| READ L_PAR IDENTIFIER R_PAR SMCOL {
		CodeNode *node = new CodeNode();
                std::string ident = $3;
                node->code = ".> " + ident + "\n";
                $$ = node;
	}

write_call: WRITE L_PAR IDENTIFIER L_SQUARE term R_SQUARE R_PAR SMCOL {
		CodeNode *node = new CodeNode();
		std::string temp = make_temp();	
		std::string ident = $3;
		CodeNode *arr = $5;
		node->code = ". " + temp + "\n";
		node->code += "=[] " + temp + ", " + ident + ", " + arr->name + "\n";
		node->code += ".> " + temp + "\n";
		$$ = node;
	}
	| WRITE L_PAR IDENTIFIER R_PAR SMCOL {
		CodeNode *node = new CodeNode();
		std::string ident = $3;
		node->code = ".> " + ident + "\n";
		$$ = node; 
	}

return_call: RETURN operation SMCOL {
		CodeNode *node = new CodeNode();
		CodeNode *op = $2;
		node->code = op->code;
		node->code += "ret " + op->name + "\n"; 
		$$ = node;
	}
	
while_call: WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL {}

if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call else_call {
		CodeNode *node = new CodeNode();
		$$ = node;
	}

elif_call: %empty /*epsilon*/ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
		// not needed for phase 4 :)
	}

else_call: %empty /*epsilon*/ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| ELSEBR L_CURL statements R_CURL {
		// TODO
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}

comparison: term LESSER term {
		// TODO
		CodeNode *node = new CodeNode();
		$$ = node;
	}
	| term GREATER term {
		// TODO
		CodeNode *node = new CodeNode();
		$$ = node;
	}
	| term EQUALTO term {
		// TODO
		CodeNode *node = new CodeNode();
		$$ = node;
	}

operation: multiplicative_operation PLUS multiplicative_operation {
		CodeNode *node = new CodeNode();
		std::string temp = make_temp();
		node->code = ". " + temp + "\n";
		CodeNode *lhs = $1;
		CodeNode *rhs = $3;
		node->code += $1->code;
                node->code += $3->code;
		
		node->code += "+ " + temp + ", " + lhs->name + ", " + rhs->name + "\n";
		node->name = temp;
		$$ = node;
	}
	| multiplicative_operation MINUS multiplicative_operation {
		CodeNode *node = new CodeNode();
		std::string temp = make_temp();
		node->code = ". " + temp + "\n";
		CodeNode *lhs = $1;
		CodeNode *rhs = $3;
		node->code += $1->code;
                node->code += $3->code;

		node->code += "- " + temp + ", " + lhs->name + ", " + rhs->name + "\n";
		node->name = temp;
		$$ = node;
	}
	| multiplicative_operation {
		CodeNode *node = $1;
		$$ = node;
	}

multiplicative_operation: term {
		CodeNode *node = $1;
		$$ = node;
	}
	| term MULT term {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                node->code = ". " + temp + "\n";
                CodeNode *lhs = $1;
                CodeNode *rhs = $3;
		node->code += $1->code;
		node->code += $3->code;
                node->code += "* " + temp + ", " + lhs->name + ", " + rhs->name + "\n";
		node->name = temp;
                $$ = node;

	}
	| term DIV term {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                node->code = ". " + temp + "\n";
                CodeNode *lhs = $1;
                CodeNode *rhs = $3;
		node->code += $1->code;
		node->code += $3->code;
                node->code += "/ " + temp + ", " + lhs->name + ", " + rhs->name + "\n";
        	node->name = temp;        
		$$ = node;

	}
	| term MOD term {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                node->code = ". " + temp + "\n";
                CodeNode *lhs = $1;
                CodeNode *rhs = $3;
		node->code += $1->code;
                node->code += $3->code;

                node->code += "% " + temp + ", " + lhs->name + ", " + rhs->name + "\n";
		node->name = temp;
                $$ = node;
	}

term: %empty /*epsilon*/ {}
	| L_PAR operation R_PAR {
		CodeNode *node = $2;
		$$ = node;
	}
	| IDENTIFIER {
		CodeNode *node = new CodeNode();
		node->name = $1;
		$$ = node;
	}
	| IDENTIFIER L_SQUARE term R_SQUARE {
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		CodeNode *arr = $3;
		std::string temp = make_temp();
		node->name = temp;
		node->code = ". " + temp + "\n";
		node->code += "=[] " + temp + ", " + ident + ", " + arr->name + "\n";
		$$ = node;
	}
	| NUMBER {
		CodeNode *node = new CodeNode();
		node->name = $1;
		$$ = node;
	}
	| function_call{}

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
