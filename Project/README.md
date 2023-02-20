# CS152 Project

## Phase 0: Language Specification

**Experimental Programming Language Name:** WING-L

**Extension for Programs:** Main.wing

**Name of Compiler:** WING-LC

| Language Feature                   | Code Example                    |
| ---------------------------------- | ------------------------------- |
| Integer scalar variables           | int i                           |
| One dimensional array of integers  | arr[x]                          |
| Assignment statements              | x = 4                           |
| Arithmetic operators               | 4 + 2, 5 - 1, 3 * 4, 4/0 etc    |
| Relational operators               | x == y, x < y, x > y, x ~= y etc|
| While loops                        | while (args) {}                 |
| If-then-else statements            | if(x){} elif(y){} else{}        |
| Read and write statements          | read(args), write(args)         |
| Comments                           | # this is a comment             |
| Functions                          | funct foo(int a) {}             |

**Comments would look like the following:** 

```
int x[10]        # Create a one dimensional array of integers of length 10

x[3] = 5         # Assign value of 5 to the 4th element of array x
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
| read               | READ       |
| return             | RETURN     |
| write              | WRITE      |
| funct              | FUNCTION   |
