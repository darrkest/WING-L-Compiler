%{
#include<string>
#include<sstream>
#include<vector>
#include<string.h>
#include <stdio.h>
#include <stdlib.h>
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

enum Type { Integer, Array };
struct Symbol {
	std::string name;
	Type type;
	std::string func_name;
};

std::vector<Symbol> symbol_table;
std::vector<std::string> func_table;

Type getType(std::string curr) {
	Type t;
	std::string currFunc = func_table[func_table.size()-1];
	for (int i = 0; i < symbol_table.size(); ++i) {
		if (curr == symbol_table[i].name && currFunc == symbol_table[i].func_name) {
			t = symbol_table[i].type;
		}
	}
	return t;
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  std::string currFunc;
  for(int i=0; i<symbol_table.size(); i++) {
	if (symbol_table[i].func_name != currFunc) {
		printf("func: %s\n", symbol_table[i].func_name.c_str());
		currFunc = symbol_table[i].func_name;
	}
	printf("   local: %s\n", symbol_table[i].name.c_str());
  }
  printf("--------------------\n");
}

int global_variable_counter = 0;
int global_variable_counter2 = 0;
int global_label_counter = 0;
int global_iftrue_counter = 0;
int global_else_counter = 0;
int global_endif_counter = 0;
int global_loop_counter = 0;
int global_loopbody_counter = 0;
int global_endloop_counter = 0;

std::string make_temp() {
        std::ostringstream os;
        os << "_temp" << global_variable_counter++;
        return os.str();
}

std::string new_label() {
        std::ostringstream os;
        os << "_label_" << global_label_counter++;
        return os.str();
}

std::string new_temp() {
        std::ostringstream os;
        os << "_temp_" << global_variable_counter2++;
        return os.str();
}

std::string new_iftrue() {
        std::ostringstream os;
        os << "if_true" << global_iftrue_counter++;
        return os.str();
}

std::string new_else() {
        std::ostringstream os;
        os << "else" << global_else_counter++;
        return os.str();
}

std::string new_endif() {
        std::ostringstream os;
        os << "endif" << global_endif_counter++;
        return os.str();
}

std::string new_loop() {
	std::ostringstream os;
	os << "beginloop" << global_loop_counter++;
	return os.str();
}

std::string new_loopbody() {
	std::ostringstream os;
	os << "loopbody" << global_loopbody_counter++;
	return os.str();
}

std::string new_endloop() {
	std::ostringstream os;
	os << "endloop" << global_endloop_counter++;
	return os.str();
}

std::string curr_endloop() {
	std::ostringstream os;
	os << "endloop" << global_endloop_counter;
	return os.str();
}

int arg_counter = -1;

bool mainFound = false;
bool funcFound = false;
bool varFound = false;

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
%token BREAK CONTINUE

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
%type <node> while_call
%type <node> assignment
%type <node> operation
%type <node> multiplicative_operation
%type <node> term
%type <node> return_call
%type <node> function_call
%type <node> func_call_arguments
%type <node> func_call_argument
%type <node> if_call
%type <node> else_call
%type <node> comparison
%type <node> break_call
%type <node> continue_call
%type <node> while_statements
%type <node> while_statement
%type <node> if_while_call
%%

prog_start: %empty /* epsilon */ {}
	| functions {
		CodeNode *node = $1;
		for (int i = 0; i < func_table.size(); ++i) {
			if (func_table[i] == "main") {
				mainFound = true;
			}
		}
		if (!mainFound) {
			yyerror("Function main not found\n");
		}
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

function: FUNCTION IDENTIFIER {
		CodeNode *node = new CodeNode;
		std::string id = $2;
		std::string funcName = id;
		
		func_table.push_back(funcName);
		node->code = "func " + id + "\n";
		$$ = node;
	}
	| L_PAR arguments R_PAR L_CURL statements R_CURL {
                CodeNode *node = new CodeNode();
		// Add the arguments code
		CodeNode *args = $2;
		node->code += args->code;
		// Add the statements code
		CodeNode *states = $5;
		node->code += states->code;

		node->code += "endfunc\n";
		arg_counter = -1;
		$$ = node;
	}
	| L_CURL statements R_CURL {
                CodeNode *node = new CodeNode();	
		CodeNode *states = $2;
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
		Symbol s;
		s.name = var_name;
		s.type = Integer;
		s.func_name = func_table[func_table.size()-1];
		symbol_table.push_back(s);
		
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
		Symbol s;
		s.name = var_name;
		s.type = Array;
		s.func_name = func_table[func_table.size()-1];
		symbol_table.push_back(s);

                CodeNode *node = new CodeNode();
                node->name = var_name;
                node->code = ".[] " + var_name + ", " + arrSize->name + "\n";
                $$ = node;
        }

declared_term: INTEGER IDENTIFIER {	
		// Add to symbol table
		std::string var_name = $2;
		varFound = false;
		std::string currFunc = func_table[func_table.size()-1];
		for (int i = 0; i < symbol_table.size(); ++i) {
			if (symbol_table[i].func_name == currFunc && symbol_table[i].name == var_name) {
				varFound = true;
			}
		}
		if (varFound) {
			yyerror("Variable redeclaration\n");
		}

		Symbol s;
		s.name = var_name;
		s.type = Integer;
		s.func_name = func_table[func_table.size()-1];
		symbol_table.push_back(s);

		CodeNode *node = new CodeNode();
		node->name = var_name;

		node->code = ". " + var_name + "\n";
		$$ = node;
	}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {
		// Add to symbol table
		std::string var_name = $2;
		varFound = false;
		std::string currFunc = func_table[func_table.size()-1];
		for (int i = 0; i < symbol_table.size(); ++i) {
                        if (symbol_table[i].func_name == currFunc && symbol_table[i].name == var_name) {
                                varFound = true;
                        }
                }
                if (varFound) {
                        yyerror("Variable redeclaration\n");
                }
		CodeNode *arrSize = $4;
		Symbol s;
		s.name = var_name;
		s.type = Array;
		s.func_name = func_table[func_table.size()-1];
		symbol_table.push_back(s);
	
		unsigned int arrNum;
                sscanf(arrSize->name.c_str(), "%d", &arrNum);
                if (arrNum <= 0) {
			yyerror("Array cannot be of size <= 0");
		}

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
	| while_call {
		CodeNode *node = $1;
		$$ = node;
	}
	| if_call {
		CodeNode *node = $1;
		$$ = node;
	}

while_statements: %empty /* epsilon */ {
                CodeNode *node = new CodeNode();
                node->code = "";
                $$ = node;
        }
        | while_statement while_statements {
                CodeNode *node = new CodeNode();
                CodeNode *state = $1;
                CodeNode *states = $2;
                node->code = state->code + states->code;
                $$ = node;
        }

while_statement: declaration {
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
        | while_call {
                CodeNode *node = $1;
                $$ = node;
        }
        | if_while_call {
                CodeNode *node = $1;
                $$ = node;
        }
        | break_call {
                CodeNode *node = $1;
                $$ = node;
        }
	| continue_call {
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
		
		funcFound = false;
		for (int i = 0; i < func_table.size(); ++i) {
			if (func_table[i] == func_name) {
				funcFound = true;
			}
		}
		if (!funcFound) {
			yyerror("Function call to function that does not exist\n");
		}

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
                CodeNode *node = $1;
		node->code += "param " + node->name + "\n";
                $$ = node;
        }

assignment: IDENTIFIER EQUAL operation SMCOL{
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		varFound = false;
		std::string currFunc = func_table[func_table.size()-1];
		for (int i = 0; i < symbol_table.size(); ++i) {
			if (symbol_table[i].name == ident && symbol_table[i].func_name == currFunc) {
				varFound = true;
			}
		}
		if (!varFound) {
			yyerror("Attempting to use variable not yet declared");
		}
		if (getType(node->name) != Integer) {
                        yyerror("Attempting to use variable of type array as integer");
                }
		CodeNode *rhs = $3;
		node->code += rhs->code;
		node->code += "= " + ident + ", " + rhs->name + "\n";
		$$ = node;
	}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL operation SMCOL {
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		varFound = false;
                std::string currFunc = func_table[func_table.size()-1];
                for (int i = 0; i < symbol_table.size(); ++i) {
                        if (symbol_table[i].name == ident && symbol_table[i].func_name == currFunc) {
                                varFound = true;
                        }
                }
                if (!varFound) {
                        yyerror("Attempting to use variable not yet declared");
                }
		if (getType(node->name) != Array) {
                        yyerror("Attempting to use variable of type integer as array");
                }
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
                node->code = ".< " + ident + "\n";
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

break_call: BREAK SMCOL {
		CodeNode *node = new CodeNode();
		std::string label = curr_endloop();
		node->code = ":= " + label + "\n";
		$$ = node;
	}

continue_call: CONTINUE SMCOL {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	
while_call: WLOOP L_PAR comparison R_PAR L_CURL while_statements R_CURL {
		CodeNode *node = new CodeNode();
                CodeNode *comp = $3;
                CodeNode *states = $6;

                std::string start_label = new_loop(); // _label_0
                std::string body_label = new_loopbody(); // _label_1
                std::string end_label = new_endloop(); // _label_2

                node->code = ". " + comp->name + "\n";
                node->code += ": " + start_label  + "\n";
                node->code += comp->code;
                node->code += "?:= " + body_label + ", " + comp->name + "\n";
                node->code += ":= " + end_label + "\n";
                node->code += ": " + body_label + "\n";
                node->code += states->code;
                node->code += ":= " + start_label + "\n";
                node->code += ": " + end_label + "\n";

                $$ = node;
	}

if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL {
		CodeNode *node = new CodeNode();
                CodeNode *comp = $3;
                CodeNode *states = $6;

                std::string true_label = new_iftrue();
                std::string end_label = new_endif();

                node->code = ". " + comp->name + "\n";
                node->code += comp->code;
                node->code += "?:= " + true_label + ", " + comp->name + "\n";
                node->code += ":= " + end_label + "\n";
                node->code += ": " + true_label + "\n";
                node->code += states->code;
                node->code += ": " + end_label + "\n";

                $$ = node;
	}
	| IFBR L_PAR comparison R_PAR L_CURL statements R_CURL else_call {
		CodeNode *node = new CodeNode();
		CodeNode *comp = $3;
		CodeNode *states = $6;
		CodeNode *_else = $8;
		
		std::string true_label = new_iftrue();
		std::string end_label = new_endif();
		std::string else_label = new_else();
	
		node->code = ". " + comp->name + "\n";
		node->code += comp->code;
		node->code += "?:= " + true_label + ", " + comp->name + "\n";
		node->code += ":= " + else_label + "\n";
		node->code += ": " + true_label + "\n";
		node->code += states->code;
		node->code += ":= " + end_label + "\n";
		node->code += ": " + else_label + "\n";
		node->code += _else->code;
		node->code += ": " + end_label + "\n";
		
		$$ = node;
	}

if_while_call: IFBR L_PAR comparison R_PAR L_CURL while_statements R_CURL {
                CodeNode *node = new CodeNode();
                CodeNode *comp = $3;
                CodeNode *states = $6;

                std::string true_label = new_iftrue();
                std::string end_label = new_endif();

                node->code = ". " + comp->name + "\n";
                node->code += comp->code;
                node->code += "?:= " + true_label + ", " + comp->name + "\n";
                node->code += ":= " + end_label + "\n";
                node->code += ": " + true_label + "\n";
                node->code += states->code;
                node->code += ": " + end_label + "\n";

                $$ = node;
        }
	| IFBR L_PAR comparison R_PAR L_CURL while_statements R_CURL else_call {
                CodeNode *node = new CodeNode();
                CodeNode *comp = $3;
                CodeNode *states = $6;
                CodeNode *_else = $8;

                std::string true_label = new_iftrue();
                std::string end_label = new_endif();
                std::string else_label = new_else();

                node->code = ". " + comp->name + "\n";
                node->code += comp->code;
                node->code += "?:= " + true_label + ", " + comp->name + "\n";
                node->code += ":= " + else_label + "\n";
                node->code += ": " + true_label + "\n";
                node->code += states->code;
                node->code += ":= " + end_label + "\n";
                node->code += ": " + else_label + "\n";
                node->code += _else->code;
                node->code += ": " + end_label + "\n";

                $$ = node;
        }

else_call: ELSEBR L_CURL statements R_CURL {
		CodeNode *node = new CodeNode();
		CodeNode *states = $3;
		node->code = states->code;
		$$ = node;
	}

comparison: term LESSER term {
                CodeNode *node = new CodeNode();
                CodeNode *term1 = $1;
                CodeNode *term2 = $3;

                node->name = new_temp();
                node->code = "< " + node->name + ", " + term1->name + ", " + term2->name + "\n";

                $$ = node;
        }
        | term GREATER term {
                CodeNode *node = new CodeNode();
                CodeNode *term1 = $1;
                CodeNode *term2 = $3;

                node->name = new_temp();
                node->code = "> " + node->name + ", " + term1->name + ", " + term2->name + "\n";

                $$ = node;
        }
        | term EQUALTO term {
                CodeNode *node = new CodeNode();
                CodeNode *term1 = $1;
                CodeNode *term2 = $3;

                node->name = new_temp();
                node->code = "= " + node->name + ", " + term1->name + ", " + term2->name + "\n";

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

term: %empty /*epsilon*/ {
		std::string errMsg = "Missing term or negative number";
		yyerror(errMsg.c_str());	
	}
	| L_PAR operation R_PAR {
		CodeNode *node = $2;
		$$ = node;
	}
	| IDENTIFIER {
		CodeNode *node = new CodeNode();
		node->name = $1;
		varFound = false;
		std::string currFunc = func_table[func_table.size()-1];
		for (int i = 0; i < symbol_table.size(); ++i) {
			if (node->name == symbol_table[i].name && currFunc == symbol_table[i].func_name) {
				varFound = true;
			}
		}
		if (!varFound) {
			yyerror("Attempting to use variable not yet declared");
		}
		if (getType(node->name) != Integer) {
			yyerror("Attempting to use variable of type array as integer");
		}
		$$ = node;
	}
	| IDENTIFIER L_SQUARE term R_SQUARE {
		CodeNode *node = new CodeNode();
		std::string ident = $1;
		varFound = false;
                std::string currFunc = func_table[func_table.size()-1];
                for (int i = 0; i < symbol_table.size(); ++i) {
                        if (node->name == symbol_table[i].name && currFunc == symbol_table[i].func_name) {
                                varFound = true;
                        }
                }
                if (!varFound) {
                        yyerror("Attempting to use variable not yet declared");
                }
		if (getType(node->name) != Array) {
			yyerror("Attempting to use variable of type integer as array");
		}
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
