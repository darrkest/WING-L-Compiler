%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA_LOWER [a-z]
ALPHA_UPPER [A-Z]
%%
{DIGIT}+ { printf("NUMBER");}
{ALPHA_LOWER} { printf("LOWERCASE");}
{ALPHA_UPPER} { printf("UPPERCASE");}
"int" 	 { printf("INTEGER");}
"sym" 	 { printf("CHAR");}
"+"	 { printf("PLUS");}
"-"	 { printf("MINUS");}
"*"	 { printf("MULT");}
"/"	 { printf("DIV");}
"("	 { printf("L_PAR");}
")"	 { printf("R_PAR");}
"="	 { printf("EQUAL");}
"<" 	 { printf("LESSER");}
">"	 { printf("GREATER");}
"=="     { printf("EQUALTO");}
"~" 	 { printf("NOT");}
"~="	 { printf("NOTEQUAL");}
"if"	 { printf("IFBR");}
"elif" 	 { printf("ELIFBR");}
"else"   { printf("ELSEBR");}
"and"    { printf("AND");} 
"or"	 { printf("OR");}
"while"  { printf("WLOOP");}
.	 {}
%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
