%{
#include <stdio.h>
int errorPosition = 1;
int errorLine = 1;
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
IDENTIFIER {ALPHA}|{ALPHA}(_|{ALPHA})*
%%
"int" 	 { printf("INTEGER\n"); errorPosition += yyleng;}
"sym" 	 { printf("CHAR\n"); errorPosition += yyleng;}
"+"	 { printf("PLUS\n"); errorPosition += yyleng;}
"-"	 { printf("MINUS\n"); errorPosition += yyleng;}
"*"	 { printf("MULT\n"); errorPosition += yyleng;}
"/"	 { printf("DIV\n"); errorPosition += yyleng;}
"("	 { printf("L_PAR\n"); errorPosition += yyleng;}
")"	 { printf("R_PAR\n"); errorPosition += yyleng;}
"="	 { printf("EQUAL\n"); errorPosition += yyleng;}
"<" 	 { printf("LESSER\n"); errorPosition += yyleng;}
">"	 { printf("GREATER\n"); errorPosition += yyleng;}
"=="     { printf("EQUALTO\n"); errorPosition += yyleng;}
"~" 	 { printf("NOT\n"); errorPosition += yyleng;}
"~="	 { printf("NOTEQUAL\n"); errorPosition += yyleng;}
"if"	 { printf("IFBR\n"); errorPosition += yyleng;}
"elif" 	 { printf("ELIFBR\n"); errorPosition += yyleng;}
"else"   { printf("ELSEBR\n"); errorPosition += yyleng;}
"and"    { printf("AND\n"); errorPosition += yyleng;} 
"or"	 { printf("OR\n"); errorPosition += yyleng;}
"while"  { printf("WLOOP\n"); errorPosition += yyleng;}
"read"   { printf("READ\n"); errorPosition += yyleng;}
"write"  { printf("WRITE\n"); errorPosition += yyleng;}
"funct"  { printf("FUNCTION\n"); errorPosition += yyleng;}
"{"      { printf("L_CURL\n"); errorPosition += yyleng;}
"}"      { printf("R_CURL\n"); errorPosition += yyleng;}
"["      { printf("L_SQUARE\n"); errorPosition += yyleng;}
"]"	 { printf("R_SQUARE\n"); errorPosition += yyleng;}

"#"(.)*	 { }
" "	 { errorPosition += yyleng; }
"\t"	 { errorPosition += yyleng; }
"\n"	 { errorPosition = 1; ++errorLine; }

"_"{IDENTIFIER} { printf("Error: Identifier can't begin with an underscore. Line %d, position %d\n", errorLine, errorPosition); exit(0);}
{DIGIT}+ { printf("NUMBER %s\n", yytext); errorPosition++;}
{IDENTIFIER} { printf("IDENTIFIER %s\n", yytext); errorPosition++;}

.        { printf("Error: Unidentified symbol \"%s\" detected. Line %d, position %d\n", yytext, errorLine, errorPosition); exit(0);}

%%

/*
int main (int argc, char *argv[]) {
  printf("Ctrl+D to quit.\n"); 
  yyin = fopen(argv[1], "r"); // Open the first file after a.out
  yylex();
  fclose(yyin);
  printf("Quitting...\n");
}
*/
