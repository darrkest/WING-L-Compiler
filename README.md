# CS152 Project

## Phase 0: Language Specification

**Experimental Programming Language Name:** WING-L

**Extension for Programs:** Main.wing

**Name of Compiler:** WING-LC

| Language Feature                   | Code Example                    |
| ---------------------------------- | ------------------------------- |
| Integer scalar variables           | int i                           |
| One dimensional array of integers  | arr[x] (x is int)               |
| Assignment statements              | x = 4                           |
| Arithmetic operators               | 4 + 2, 5 - 1, 3 * 4, 4/0 etc    |
| Relational operators               | x == y                          |
| While loops                        | while (bool) {}                 |
| If-then-else statements            | if(bool) elif(bool) else(bool)  |
| Read and write statements          | read(str), write(str)           |
| Comments                           | # this is a comment            |
| Functions                          | [return type] \[name]([args]){}  |

**Comments would look like the following:** 

```
int x[10]        # Create a one dimensional array of integers of length 10

x[3] = 5         # Assign value of 5 to the 4th element of array x
```

**Valid identifier:**

**Case sensitive?:**

**Whitespaces?:**

| Symbol in Language | Token Name |
| ------------------ | ---------- |
| int                | INTEGER    |
| +                  | PLUS       |
| -                  | MINUS      |
| *                  | MULT       |
| /                  | DIV        |
| <                  | LESSER     |
| >                  | GREATER    |
| ==                 | EQUALTO    |
| !=                 | NOTEQUAL   |
