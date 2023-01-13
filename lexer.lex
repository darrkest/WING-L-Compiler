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
"\n"	 { printf("Number of integers: %d\n", numIntegers);
	   printf("Number of operators: %d\n", numOperators);
	   printf("Number of parenthesis: %d\n", numParenthesis);
	   printf("Number of equals: %d\n", numEquals); 
	 }
.	 { printf("Invalid character detected.\n");
           return;  }
%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
