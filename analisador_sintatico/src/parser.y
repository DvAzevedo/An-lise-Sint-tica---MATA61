%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
void yyerror(const char *s);
extern int yylex(void);  // Added prototype for yylex
extern int yylineno;
%}

%union {
    int i_val;
    float f_val;
    char *s_val;
    ASTNode* ast;  // Added union member for AST nodes
}

%token <s_val> ID
%token <i_val> INT_NUM
%token <f_val> FLOAT_NUM
%token INT FLOAT IF ELSE FOR

%type <ast> program statement_list statement declaration attribution if_statement condition expression

%left '+' '-'
%left '*' '/'

%start program

%%
program:
    statement_list 
    { 
        $$ = create_node(AST_NODE_PROGRAM, "Program", @$.first_line);
        add_child($$, $1);
        printf("program\n");
        print_ast($$, 0);
    }
    ;

statement_list:
    statement_list statement 
    { 
        $$ = create_node(AST_NODE_STATEMENT, "Statement", @2.first_line);
        add_child($$, $1);
        add_child($$, $2);
        printf("statement_list -> statement\n");
    }
  | statement 
    { 
        $$ = $1;
        printf("statement_list -> statement\n");
    }
    ;

statement:
    declaration 
    { 
        $$ = $1;
        printf("statement -> declaration\n");
    }
  | attribution 
    { 
        $$ = $1;
        printf("statement -> attribution\n");
    }
  | if_statement 
    { 
        $$ = $1;
        printf("statement -> if_statement\n");
    }
    // ...outras produções...
    ;

declaration:
    INT ID ';' 
    { 
        $$ = create_node(AST_NODE_DECLARATION, "Declaration", @2.first_line);
        add_child($$, create_node(AST_NODE_TYPE, "int", @1.first_line));
        add_child($$, create_node(AST_NODE_ID, $2, @2.first_line));
        printf("declaration -> INT ID ;\n");
    }
  | FLOAT ID ';' 
    { 
        $$ = create_node(AST_NODE_DECLARATION, "Declaration", @2.first_line);
        add_child($$, create_node(AST_NODE_TYPE, "float", @1.first_line));
        add_child($$, create_node(AST_NODE_ID, $2, @2.first_line));
        printf("declaration -> FLOAT ID ;\n");
    }
    // ...vetores e outras declarações...
    ;

attribution:
    ID '=' INT_NUM ';' 
    { 
        $$ = create_node(AST_NODE_ATTRIBUTION, "Attribution", @2.first_line);
        add_child($$, create_node(AST_NODE_ID, $1, @1.first_line));
        char buffer[32];
        sprintf(buffer, "%d", $3);
        add_child($$, create_node(AST_NODE_INT, buffer, @3.first_line));
        printf("attribution -> ID = INT_NUM ;\n");
    }
  | ID '=' FLOAT_NUM ';' 
    { 
        $$ = create_node(AST_NODE_ATTRIBUTION, "Attribution", @2.first_line);
        add_child($$, create_node(AST_NODE_ID, $1, @1.first_line));
        char buffer[32];
        sprintf(buffer, "%f", $3);
        add_child($$, create_node(AST_NODE_FLOAT, buffer, @3.first_line));
        printf("attribution -> ID = FLOAT_NUM ;\n");
    }
    ;

if_statement:
    IF '(' condition ')' '{' statement_list '}' 
    { 
        $$ = create_node(AST_NODE_IF, "IfStatement", @1.first_line);
        add_child($$, $3);
        add_child($$, $6);
        printf("if_statement -> IF ( condition ) { statement_list }\n");
    }
  | IF '(' condition ')' '{' statement_list '}' ELSE '{' statement_list '}' 
    { 
        $$ = create_node(AST_NODE_IF, "IfStatement", @1.first_line);
        add_child($$, $3);
        add_child($$, $6);
        add_child($$, $10);
        printf("if_statement -> IF ( condition ) { statement_list } ELSE { statement_list }\n");
    }
    ;

condition:
    expression '<' expression 
    { 
        $$ = create_node(AST_NODE_CONDITION, "Condition", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, "<", @2.first_line));
        add_child($$, $3);
        printf("condition -> expression < expression\n");
    }
  | expression '>' expression 
    { 
        $$ = create_node(AST_NODE_CONDITION, "Condition", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, ">", @2.first_line));
        add_child($$, $3);
        printf("condition -> expression > expression\n");
    }
  | expression "==" expression 
    { 
        $$ = create_node(AST_NODE_CONDITION, "Condition", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, "==", @2.first_line));
        add_child($$, $3);
        printf("condition -> expression == expression\n");
    }
    ;

expression:
    INT_NUM 
    { 
        char buffer[32];
        sprintf(buffer, "%d", $1);
        $$ = create_node(AST_NODE_INT, buffer, @1.first_line);
        printf("expression -> INT_NUM\n");
    }
  | FLOAT_NUM 
    { 
        char buffer[32];
        sprintf(buffer, "%f", $1);
        $$ = create_node(AST_NODE_FLOAT, buffer, @1.first_line);
        printf("expression -> FLOAT_NUM\n");
    }
  | ID 
    { 
        $$ = create_node(AST_NODE_ID, $1, @1.first_line);
        printf("expression -> ID\n");
    }
  | expression '+' expression 
    { 
        $$ = create_node(AST_NODE_EXPRESSION, "Expression", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, "+", @2.first_line));
        add_child($$, $3);
        printf("expression -> expression + expression\n");
    }
  | expression '-' expression 
    { 
        $$ = create_node(AST_NODE_EXPRESSION, "Expression", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, "-", @2.first_line));
        add_child($$, $3);
        printf("expression -> expression - expression\n");
    }
  | expression '*' expression 
    { 
        $$ = create_node(AST_NODE_EXPRESSION, "Expression", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, "*", @2.first_line));
        add_child($$, $3);
        printf("expression -> expression * expression\n");
    }
  | expression '/' expression 
    { 
        $$ = create_node(AST_NODE_EXPRESSION, "Expression", @2.first_line);
        add_child($$, $1);
        add_child($$, create_node(AST_NODE_OPERATOR, "/", @2.first_line));
        add_child($$, $3);
        printf("expression -> expression / expression\n");
    }
  | '(' expression ')' 
    { 
        $$ = $2;
        printf("expression -> ( expression )\n");
    }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

/* Comment out or remove the extra main() definition */
// int main(void) {
//     // ...existing main code...
