%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA_LOWER [a-z]
ALPHA_UPPER [A-Z]
%%
{DIGIT}+ { printf("NUMBER\n");}
{ALPHA_LOWER} { printf("LOWERCASE\n");}
{ALPHA_UPPER} { printf("UPPERCASE\n");}
"int" 	 { printf("INTEGER\n");}
"sym" 	 { printf("CHAR\n");}
"+"	 { printf("PLUS\n");}
"-"	 { printf("MINUS\n");}
"*"	 { printf("MULT\n");}
"/"	 { printf("DIV\n");}
"("	 { printf("L_PAR\n");}
")"	 { printf("R_PAR\n");}
"="	 { printf("EQUAL\n");}
"<" 	 { printf("LESSER\n");}
">"	 { printf("GREATER\n");}
"=="     { printf("EQUALTO\n");}
"~" 	 { printf("NOT\n");}
"~="	 { printf("NOTEQUAL\n");}
"if"	 { printf("IFBR\n");}
"elif" 	 { printf("ELIFBR\n");}
"else"   { printf("ELSEBR\n");}
"and"    { printf("AND\n");} 
"or"	 { printf("OR\n");}
"while"  { printf("WLOOP\n");}
.	 {}
%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
