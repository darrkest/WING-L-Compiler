%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-z]
%%
{DIGIT}+ {}
"+"	 {}
"-"	 {}
"*"	 {}
"/"	 {}
"("	 {}
")"	 {}
"="	 {} 
.	 {}
%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
