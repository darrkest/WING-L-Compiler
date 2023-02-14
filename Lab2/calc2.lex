%{
#include "y.tab.h"
%}

DIGIT [0-9]
ALPHA [a-z]
%%
{DIGIT}+ { return INT;}
[a-zA-z]+ {return IDENT;}
"{" {return LBR;}
"}" {return RBR;}
"," {return COMMA;}
"(" {return LPR;}
")" {return RPR;}
"\n" {}
[\t]+ {}

%%
