%{
#include <stdio.h>
%}

DIGIT [0-9]

%%
{DIGIT}+ { printf("NUMBER: %s\n", yytext); }
"+"	 { printf("ADD\n"); }
"-"	 { printf("SUB\n"); }
"*"	 { printf("MULT\n"); }
"/"	 { printf("DIV\n"); }
"("	 { printf("L_PAREN\n"); }
")"	 { printf("R_PAREN\n"); }
"="	 { printf("EQUAL\n"); } 
.	 { printf("Invalid character detected.\n"); }
%%

main (void) {
  printf("Ctrl+D to quit.\n"); 
  yylex();
  printf("Quitting...");
}
