%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    extern FILE *yyin;
    extern int yylex();
    extern int yylineno;
    void yyerror(const char *s);
    FILE *out;

    // Declarações de funções e variáveis do analisador léxico
    extern void add_to_symbol_table(const char *name, int line);
    extern int getId(const char *name);
    extern void print_symbol_table();
%}

// Defina YYSTYPE como uma união
%union {
    char* str;  // Para strings (IDs, literais, etc.)
    int num;    // Para números (DIGIT, DIGITF, etc.)
}

// Declare os tokens com seus tipos
%token <str> ID STR
%token <num> DIGIT DIGITF
%token IF ELSE WHILE RETURN VOID INT FLOAT
%token PLUS MINUS MULT DIV LT LTE GT GTE EQ NEQ ASSIGN SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE

%%

// Regras de produção
program:
    | program declaration
    | program statement
    ;

declaration:
    type_specifier ID SEMI
    {
        add_to_symbol_table($2, yylineno);
        fprintf(out, "<ID,%d>\n", getId($2));
    }
    ;

type_specifier:
    INT
    | FLOAT
    | VOID
    ;

statement:
    expression SEMI
    | IF LPAREN expression RPAREN statement
    | IF LPAREN expression RPAREN statement ELSE statement
    | WHILE LPAREN expression RPAREN statement
    | RETURN expression SEMI
    ;

expression:
    ID ASSIGN expression
    | expression PLUS expression
    | expression MINUS expression
    | expression MULT expression
    | expression DIV expression
    | expression LT expression
    | expression LTE expression
    | expression GT expression
    | expression GTE expression
    | expression EQ expression
    | expression NEQ expression
    | LPAREN expression RPAREN
    | ID
    | DIGIT
    | DIGITF
    | STR
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático na linha %d: %s\n", yylineno, s);
}

int main(int argc, char *argv[]) {
    FILE *arquivo = fopen(argv[1], "r");
    if (!arquivo) {
        printf("Arquivo inexistente\n");
        return -1;
    }
    yyin = arquivo;
    out = fopen(argv[2], "w");
    if (!out) {
        printf("Erro ao abrir arquivo de saída\n");
        return -1;
    }
    yyparse();
    print_symbol_table();
    fclose(out);
    fclose(arquivo);
    return 0;
}
