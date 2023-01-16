%{
#include <stdio.h>
int numIntegers = 0;
int numOperators = 0;
int numParenthesis = 0;
int numEquals = 0;
%}

DIGIT [0-9]
ALPHA [a-z]
%%
{DIGIT}+ { printf("NUMBER: %s\n", yytext); 
	   numIntegers++;
	 }
"+"	 { printf("ADD\n"); 
           numOperators++;
	 }
"-"	 { printf("SUB\n"); 
	   numOperators++;
	 }
"*"	 { printf("MULT\n"); 
	   numOperators++;
	 }
"/"	 { printf("DIV\n"); 
	   numOperators++;
	 }
"("	 { printf("L_PAREN\n"); 
	   numParenthesis++;
	 }
")"	 { printf("R_PAREN\n"); 
	   numParenthesis++;
	 }
"="	 { printf("EQUAL\n"); 
	   numEquals++;
	 } 
.	 { printf("Invalid character detected.\n");
           return;  }
%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Integers: %d\n", numIntegers);
  printf("Operators: %d\n", numOperators);
  printf("Parenthesis: %d\n", numParenthesis);
  printf("Equals: %d\n", numEquals);
  printf("Quitting...\n");
}
