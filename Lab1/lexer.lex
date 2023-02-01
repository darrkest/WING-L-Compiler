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
{DIGIT}+ { numIntegers++; return NUMBER;}
"+"	 {  numOperators++; return ADD;}
"-"	 { numOperators++; return SUB;}
"*"	 { numOperators++; return MULT;}
"/"	 { numOperators++; return DIV;}
"("	 { numParenthesis++; return L_PAREN;}
")"	 { numParenthesis++; return R_PAREN;}
"="	 { numEquals++; return EQUAL;} 
.	 { printf("Invalid character detected.\n"); return;}
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
