# CS152 Project

## Phase 0: Language Specification

**Experimental Programming Language Name:** WING-L

**Extension for Programs:** Main.wing

**Name of Compiler:** WING-LC

| Language Feature                   | Code Example                    |
| ---------------------------------- | ------------------------------- |
| Integer scalar variables           | int i;                          |
| One dimensional array of integers  | arr[x];                         |
| Assignment statements              | x = 4;                          |
| Arithmetic operators               | 4 + 2, 5 - 1, 3 * 4, 4/0 etc    |
| Relational operators               | x == y, x < y, x > y, x ~= y etc|
| While loops                        | while (args) {}                 |
| If-then-else statements            | if(x){} elif(y){} else{}        |
| Read and write statements          | read(args);, write(args);       |
| Comments                           | # this is a comment             |
| Functions                          | funct foo(int a) {}             |

**Comments would look like the following:** 

```
int x[10];        # Create a one dimensional array of integers of length 10

x[3] = 5;         # Assign value of 5 to the 4th element of array x
```

**Valid identifier:** Letters and underscores, but can't start with an underscore

**Case sensitive?:** Yes

**Whitespaces?:** Ignored

| Symbol in Language | Token Name |
| ------------------ | ---------- |
| {DIGIT}+           | NUMBER     |
| {IDENTIFIER}       | IDENTIFIER |
| int                | INTEGER    |
| sym                | CHAR       |
| +                  | PLUS       |
| -                  | MINUS      |
| *                  | MULT       |
| /                  | DIV        |
| (                  | L_PAR      |
| )                  | R_PAR      |
| <                  | LESSER     |
| >                  | GREATER    |
| =                  | EQUAL      |
| ==                 | EQUALTO    |
| ~=                 | NOTEQUAL   |
| if                 | IFBR       |
| elif               | ELIFBR     |
| else               | ELSEBR     |
| while              | WLOOP      | 
| and                | AND        |
| or                 | OR         |
| ~                  | NOT        |
| {                  | L_CURL     |
| }                  | R_CURL     |
| [                  | L_SQUARE   |
| ]                  | R_SQUARE   |
| ,                  | COMMA      |
| ;                  | SMCOL      |
| read               | READ       |
| return             | RETURN     |
| break              | BREAK      |
| continue           | CONTINUE   |
| write              | WRITE      |
| funct              | FUNCTION   |

## Phase 2: Parser Generation (using bison)

Grammar: 

**prog_start: %empty /* epsilon */ {printf("prog_start->epsilon\n");}
	| functions {printf("prog_start -> functions\n");}**

**functions: function {printf("functions -> function\n");}
	| function functions {printf("functions -> function functions\n");}**

**function: FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL {printf("function -> FUNCTION IDENTIFIER L_PAR arguments R_PAR L_CURL statements R_CURL\n");}
	| FUNCTION IDENTIFIER L_CURL statements R_CURL {printf("function -> FUNCTION IDENTIFIER L_CURL statements R_CURL\n");}**

**arguments: argument {printf("arguments -> argument\n");}
	| argument COMMA arguments {printf("arguments -> COMMA arguments\n");}**

**argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
	| INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
        | INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE {printf("argument -> INTEGER IDENTIFIER L_SQUARE NUMBER R_SQUARE\n");}
	| term {printf("argument -> term\n");}**

**statements: %empty /* epsilon */ {printf("statements -> epsilon\n");}
	| statement statements {printf("statements -> statement statements\n");}**

**statement: declaration {printf("statement -> declaration\n");}
        | function_call {printf("statement -> function_call\n");}
	| assignment {printf("statement -> assignment\n");}
	| read_call   {printf("statement -> read_call\n");}
	| write_call {printf("statement -> write_call\n");}
	| return_call {printf("statement -> return_call\n");}
	| while_call {printf("statement -> while_call\n");}
	| if_call {printf("statement -> if_call\n");}
	| elif_call {printf("statement -> elif_call\n");}
	| else_call {printf("statement -> else_call\n");}**
	
**declaration: INTEGER IDENTIFIER {printf("declaration -> INTEGER IDENTIFIER\n");}
	| INTEGER IDENTIFIER L_SQUARE term R_SQUARE {printf("declaration -> INTEGER IDENTIFIER L_SQUARE term R_SQUARE\n");}**

**function_call: IDENTIFIER L_PAR arguments R_PAR {printf("function_call -> IDENTIFIER L_PAR arguments R_PAR\n");}
	| IDENTIFIER L_PAR operation R_PAR { printf("function_call -> IDENTIFIER L_PAR operation R_PAR\n");}**

**assignment: IDENTIFIER EQUAL NUMBER {printf("assignment -> IDENTIFIER EQUAL NUMBER\n");}
	| IDENTIFIER EQUAL IDENTIFIER {printf("assignment -> IDENTIFIER EQUAL IDENTIFIER\n");}
	| IDENTIFIER EQUAL operation {printf("assignment -> IDENTIFIER EQUAL operation\n");}
	| IDENTIFIER EQUAL function_call{printf("assignment -> IDENTIFIER EQUAL function_call\n");}**

**read_call: READ L_PAR IDENTIFIER R_PAR {printf("read_call -> READ L_PAR IDENTIFIER R_PAR\n");}**

**write_call: WRITE L_PAR IDENTIFIER R_PAR {printf("write_call -> WRITE L_PAR IDENTIFIER R_PAR\n");}**

**return_call: RETURN IDENTIFIER {printf("return_call -> RETURN IDENTIFIER\n");}
	| RETURN NUMBER { printf("return_call -> RETURN NUMBER\n");}
	| RETURN operation { printf("return_call -> RETURN operation\n");}**

**while_call: WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL { printf("while_call -> WLOOP L_PAR comparison R_PAR L_CURL statements R_CURL\n");}**

**if_call: IFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call else_call {printf("if_call -> IFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call else_call\n");}**

**elif_call: %empty /*epsilon*/ {printf("elif_call -> epsilon\n");} | ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL elif_call {printf("elif_call -> ELIFBR L_PAR comparison R_PAR L_CURL statements R_CURL\n");}**

**else_call: %empty /*epsilon*/ {printf("else_call -> epsilon\n");} | ELSEBR L_CURL statements R_CURL {printf("else_call -> ELSEIF L_CURL statements R_CURL\n");}**

**comparison: term LESSER term { printf("comparison -> term LESSER term\n");}
	| term GREATER term { printf("comparison -> term GREATER term\n");}
	| term EQUALTO term {printf("comparison -> term EQUALTO term\n");}**

**operation: term addop term { printf("operation -> term addop term\n");}
	| term mulop term { printf("operation -> term mulop term\n");}**

**term: %empty /*epsilon*/ {printf("term -> epsilon\n");}
	| IDENTIFIER {printf("term -> IDENTIFIER\n");}
	| NUMBER {printf("term -> NUMBER\n");}
	| function_call{printf("term -> function_call\n");}**

**addop: PLUS { printf("addop -> PLUS\n");}
	| MINUS {printf("addop -> MINUS\n");}**

**mulop: MULT { printf("mulop -> MULT\n");}
	| DIV { printf("mulop -> DIV\n");}**
