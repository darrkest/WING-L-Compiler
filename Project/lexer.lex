%option noyywrap
%{
#include "y.tab.h"
#include <stdio.h>
#include <string.h>
int errorPosition = 1;
int errorLine = 1;

extern int identToken;
extern int numberToken;
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
IDENTIFIER {ALPHA}|{ALPHA}(_|{ALPHA})*
%%
"int" 	 { errorPosition += yyleng; return INTEGER;}
"sym" 	 { errorPosition += yyleng; return CHAR;}
"+"	 { errorPosition += yyleng; return PLUS;}
"-"	 { errorPosition += yyleng; return MINUS;}
"*"	 { errorPosition += yyleng; return MULT;}
"/"	 { errorPosition += yyleng; return DIV;}
"%"    { errorPosition += yyleng; return MOD;}
"("	 { errorPosition += yyleng; return L_PAR;}
")"	 { errorPosition += yyleng; return R_PAR;}
":="    { errorPosition += yyleng; return ASSIGN;}
"="	 { errorPosition += yyleng; return EQUAL;}
"<" 	 { errorPosition += yyleng; return LESSER;}
">"	 { errorPosition += yyleng; return GREATER;}
"=="     { errorPosition += yyleng; return EQUALTO;}
"~" 	 { errorPosition += yyleng; return NOT;}
"~="	 { errorPosition += yyleng; return NOTEQUAL;}
"if"	 { errorPosition += yyleng; return IFBR;}
"elif" 	 { errorPosition += yyleng; return ELIFBR;}
"else"   { errorPosition += yyleng; return ELSEBR;}
"and"    { errorPosition += yyleng; return AND;} 
"or"	 { errorPosition += yyleng; return OR;}
"while"  { errorPosition += yyleng; return WLOOP;}
"read"   { errorPosition += yyleng; return READ;}
"write"  { errorPosition += yyleng; return WRITE;}
"funct"  { errorPosition += yyleng; return FUNCTION;}
"{"      { errorPosition += yyleng; return L_CURL;}
"}"      { errorPosition += yyleng; return R_CURL;}
"["      { errorPosition += yyleng; return L_SQUARE;}
"]"	 { errorPosition += yyleng; return R_SQUARE;}
","	 { errorPosition += yyleng; return COMMA;}
"return" { errorPosition += yyleng; return RETURN;}

"#"(.)*	 { }
" "	 { errorPosition += yyleng; }
"\t"	 { errorPosition += yyleng; }
"\n"	 { errorPosition = 1; ++errorLine; }

"_"{IDENTIFIER} { printf("Error: Identifier can't begin with an underscore. Line %d, position %d\n", errorLine, errorPosition); exit(0);}
{DIGIT}+ { 
  errorPosition += yyleng;
  char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  numberToken = atoi(yytext);
  return NUMBER;
 }
{IDENTIFIER} { 
  errorPosition += yyleng;
  char *token = new char[yyleng];
  strcpy(token, yytext);
  yylval.op_val = token;
  identToken = atoi(yytext);
  return IDENTIFIER;
}

.        { printf("Error: Unidentified symbol \"%s\" detected. Line %d, position %d\n", yytext, errorLine, errorPosition); exit(0);}

%%
