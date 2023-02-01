%{
#include "y.tab.h"
%}

DIGIT [0-9]
ALPHA [a-z]
%%
{DIGIT}+ { return NUMBER;}
"+"	 { return ADD;}
"-"	 { return SUB;}
"*"	 { return MULT;}
"/"	 { return DIV;}
"("	 { return L_PAREN;}
")"	 { return R_PAREN;}
"="	 { return EQUAL;} 
.	 { printf("Invalid character detected.\n"); return;}
%%

