%{
#include "ast.h"      // Inclui a definição de ASTNode
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

// ...removed duplicate ASTNode definition...

/* Protótipos das funções para criar e imprimir a árvore */
ASTNode* createASTNode(const char* label, int num, ...);
void printAST(ASTNode* node, int level);

/* Nó raiz da árvore */
ASTNode* root;

extern int yylex();
void yyerror(const char *s);
%}

/* Definindo os tipos dos valores semânticos */
%union {
    char* str;
    ASTNode* node;
    int intval;
    float floatval;
}

/* Tokens retornados pelo lexer */
%token <str> ID
%token <intval> INT_LITERAL
%token <floatval> FLOAT_LITERAL
%token STR
%token INT FLOAT IF ELSE WHILE RETURN VOID
%token LE GE EQ NE       /* <-- Adicionados */

/* Declaração dos tipos dos não-terminais que terão um ASTNode* */
%type <node> program statement_list statement declaration attribution if_statement while_statement compound_statement jump_statement expression
%type <node> function_definition
%type <str> type

/* Precedência dos operadores */
%left '+' '-'
%left '*' '/'
%left LE GE EQ NE '<' '>'
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/* Símbolo inicial */
%start program

%%

program:
    function_definition { root = $1; }
  | statement_list { root = $1; }
  ;

function_definition:
    type ID '(' ')' compound_statement
      { $$ = createASTNode("function_definition", 3, createASTNode($1, 0), createASTNode($2, 0), $5); }
  ;

statement_list:
      statement_list statement { $$ = createASTNode("statement_list", 2, $1, $2); }
    | statement { $$ = createASTNode("statement_list", 1, $1); }
    ;

statement:
      declaration
    | attribution
    | if_statement
    | while_statement
    | compound_statement
    | jump_statement
    ;

declaration:
      type ID ';' { $$ = createASTNode("declaration", 2, createASTNode($1, 0), createASTNode($2, 0)); }
    ;

type:
      INT { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    | VOID { $$ = "void"; }
    ;

attribution:
      ID '=' expression ';' { $$ = createASTNode("attribution", 2, createASTNode($1, 0), $3); }
    ;

if_statement:
      IF '(' expression ')' statement %prec LOWER_THAN_ELSE { $$ = createASTNode("if_statement", 2, $3, $5); }
    | IF '(' expression ')' statement ELSE statement { $$ = createASTNode("if_statement", 3, $3, $5, $7); }
    ;

while_statement:
      WHILE '(' expression ')' statement { $$ = createASTNode("while_statement", 2, $3, $5); }
    ;

compound_statement:
      '{' statement_list '}' { $$ = createASTNode("compound_statement", 1, $2); }
    ;

jump_statement:
      RETURN expression ';' { $$ = createASTNode("return_statement", 1, $2); }
    | RETURN ';' { $$ = createASTNode("return_statement", 0); }
    ;

expression:
      expression '+' expression { $$ = createASTNode("add", 2, $1, $3); }
    | expression '-' expression { $$ = createASTNode("sub", 2, $1, $3); }
    | expression '*' expression { $$ = createASTNode("mul", 2, $1, $3); }
    | expression '/' expression { $$ = createASTNode("div", 2, $1, $3); }
    | expression LE expression { $$ = createASTNode("le", 2, $1, $3); }
    | expression GE expression { $$ = createASTNode("ge", 2, $1, $3); }
    | expression EQ expression { $$ = createASTNode("eq", 2, $1, $3); }
    | expression NE expression { $$ = createASTNode("ne", 2, $1, $3); }
    | expression '<' expression { $$ = createASTNode("lt", 2, $1, $3); }
    | expression '>' expression { $$ = createASTNode("gt", 2, $1, $3); }
    | '(' expression ')' { $$ = $2; }
    | ID { $$ = createASTNode("ID", 1, createASTNode($1, 0)); }
    | INT_LITERAL { 
          char buffer[50];
          snprintf(buffer, sizeof(buffer), "%d", $1);
          $$ = createASTNode("INT_LITERAL", 1, createASTNode(buffer, 0)); 
      }
    | FLOAT_LITERAL { 
          char buffer[50];
          snprintf(buffer, sizeof(buffer), "%f", $1);
          $$ = createASTNode("FLOAT_LITERAL", 1, createASTNode(buffer, 0)); 
      }
    ;

%%

/* Implementação da função que cria nós da árvore.
   Ela utiliza argumentos variáveis para anexar os nós-filho. */
ASTNode* createASTNode(const char* label, int num, ...) {
    ASTNode* node = (ASTNode*) malloc(sizeof(ASTNode));
    strncpy(node->label, label, 49);
    node->label[49] = '\0';
    node->num_children = num;
    if (num > 0) {
        node->children = (ASTNode**) malloc(num * sizeof(ASTNode*));
        va_list args;
        va_start(args, num);
        for (int i = 0; i < num; i++) {
            node->children[i] = va_arg(args, ASTNode*);
        }
        va_end(args);
    } else {
        node->children = NULL;
    }
    return node;
}

/* Função recursiva para imprimir a árvore sintática com recuo */
void printAST(ASTNode* node, int level) {
    if (!node) return;
    for (int i = 0; i < level; i++) {
        printf("    ");
    }
    printf("%s\n", node->label);
    for (int i = 0; i < node->num_children; i++) {
        printAST(node->children[i], level + 1);
    }
}

/* Função de tratamento de erros */
void yyerror(const char* s) {
    fprintf(stderr, "Erro: %s\n", s);
}

extern FILE *yyin;
int yyparse();

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Could not open %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    yyparse();
    printAST(root, 0);
    return 0;
}