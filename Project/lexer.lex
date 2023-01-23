%{
#include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
IDENTIFIER {ALPHA}|{ALPHA}(_|{ALPHA})*
%%
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
"read"   { printf("READ\n");}
"write"  { printf("WRITE\n");}
"funct"  { printf("FUNCTION\n");}
"{"      { printf("L_CURL\n");}
"}"      { printf("R_CURL\n");}
"["      { printf("L_SQUARE\n");}
"]"	 { printf("R_SQUARE\n");}
" "	 { }
"\t"	 { }
"\n"	 { }

"_"{IDENTIFIER} { printf("Error: Identifier can't begin with an underscore.\n"); exit(0);}
{DIGIT}+ { printf("NUMBER %s\n", yytext);}
{IDENTIFIER} { printf("IDENTIFIER %s\n", yytext);}

.        { printf("Error: Unidentified symbol detected.\n"); exit(0);}

%%

int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
