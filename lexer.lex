%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-z]
%%
{DIGIT}+ { printf("NUMBER: %s\n", yytext); }
"+"	 { printf("ADD\n"); }
"-"	 { printf("SUB\n"); }
"*"	 { printf("MULT\n"); }
"/"	 { printf("DIV\n"); }
"("	 { printf("L_PAREN\n"); }
")"	 { printf("R_PAREN\n"); }
"="	 { printf("EQUAL\n"); } 
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
