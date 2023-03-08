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
%type <op_val> term
%type <op_val> operation
%type <op_val> multiplicative_operation
%type <node> return_call
%type <node> assignment
%type <node> prog_start
%type <node> functions 
%type <node> function
%type <node> arguments
%type <node> argument
%type <node> declared_term
%type <node> declaration
%type <node> statements
%type <node> statement
%type <node> write_call

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
		printf("func %s\n", func_name.c_str());
		
	}	
	  L_PAR arguments R_PAR L_CURL statements R_CURL {
		printf("endfunc\n");	
	}
	| FUNCTION IDENTIFIER 
	{
		std::string func_name $2;
                Type t = Function;
                temp_add_to_symbol_table(func_name,t);
                printf("func %s\n", func_name.c_str());

	}
	  L_CURL statements R_CURL {
		printf("endfunc\n");
	}

arguments: argument {}			
	| argument COMMA arguments {}
	| %empty {	
		CodeNode *node = new CodeNode();
		$$ = node;
	}

argument: %empty /* epsilon */ {}
	| declared_term {}
	| term {}
	| operation {}

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

statements: %empty /* epsilon */ {
		CodeNode *node = new CodeNode();
		node->code = "";
		$$ = node;
	}
	| statement statements {
		CodeNode *node = new CodeNode();
                CodeNode *node1 = $1;
                CodeNode *node2 = $2;
		node->code = "";
                node->code = node1->code + node2->code;
                $$ = node;
	}

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
	
declaration: declared_term SMCOL{
	CodeNode *node = new CodeNode();
	node->code = "";
	$$ = node;
}

function_call: IDENTIFIER L_PAR arguments R_PAR {}

assignment: IDENTIFIER EQUAL operation SMCOL{
		std::string ident = $1;
		std::string assigned = $3;
		CodeNode *node = new CodeNode();
		node->code = "= " + ident + ", " + assigned + "\n";
		$$ = node;
		
		printf("= %s, %s\n", ident.c_str(), assigned.c_str());
	}
	| IDENTIFIER L_SQUARE term R_SQUARE EQUAL operation SMCOL {
		std::string ident = $1;
		std::string arrNum = $3;
		std::string assigned = $6;
		CodeNode *node = new CodeNode();
		node->code = "[]= " + ident + ", " + arrNum + ", " +  assigned + "\n";
		$$ = node;
		
		printf("[]= %s, %s, %s\n", ident.c_str(), arrNum.c_str(), assigned.c_str());
	}
/*	| IDENTIFIER EQUAL function_call SMCOL {
		std::string ident = $1;
		std::string funct = $3;
		CodeNode *node = new CodeNode();
		node->code = "= " + ident + ", " + funct + "\n";
		$$ = node;
		printf("= %s, %s\n", ident.c_str(), funct.c_str());
	}
*/
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
		std::string ident = $3;

		CodeNode *node = new CodeNode();
		node->code = ".> " + ident + "\n";
		$$ = node;  

		printf(".> %s\n", ident.c_str());
	}

return_call: RETURN term SMCOL {
		std::string ident = $2;
		CodeNode *node = new CodeNode;
		node->code = "ret " + ident + "\n";
		$$ = node;	
		printf("ret %s\n", ident.c_str());	
	}
	| RETURN operation SMCOL {
		std::string ident = $2;
		CodeNode *node = new CodeNode;
		node->code = "ret " + ident + "\n";
		$$ = node;
		printf("ret %s\n", ident.c_str());
	}	
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
	| multiplicative_operation {
		$$ = $1;
	}

multiplicative_operation: term {
		CodeNode *node = new CodeNode();
		$$ = $1;	
	}
	| term MULT term {
		CodeNode *node = new CodeNode();
		std::string temp = make_temp();
                std::string lhs = $1;
                std::string rhs = $3;
                node->code = ". " + temp + "\n";
                printf(". %s\n", temp.c_str());
                node->code = "* " + temp + ", " + lhs + ", " + rhs + "\n";
                printf("* %s, %s, %s\n", temp.c_str(), lhs.c_str(), rhs.c_str());
	}
	| term DIV term {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                std::string lhs = $1;
                std::string rhs = $3;
                node->code = ". " + temp + "\n";
                printf(". %s\n", temp.c_str());
                node->code = "/ " + temp + ", " + lhs + ", " + rhs + "\n";
                printf("/ %s, %s, %s\n", temp.c_str(), lhs.c_str(), rhs.c_str());
	}
	| term MOD term {
		CodeNode *node = new CodeNode();
                std::string temp = make_temp();
                std::string lhs = $1;
                std::string rhs = $3;
                node->code = ". " + temp + "\n";
                printf(". %s\n", temp.c_str());
                node->code = "%% " + temp + ", " + lhs + ", " + rhs + "\n";
                printf("%% %s, %s, %s\n", temp.c_str(), lhs.c_str(), rhs.c_str());
	}

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
