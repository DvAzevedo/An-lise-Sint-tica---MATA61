%{
#include "parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifndef VOID
#define VOID 265  // Defina um valor compatível com o parser
#endif

// Use extern instead:
extern YYSTYPE yylval;

/* Estrutura e funções para tabela de símbolos */
struct Symbol {
    char *name;
    int line;
    struct Symbol *next;
};
struct Symbol *symbolTable = NULL;
  
void addSymbol(const char *name, int line) {
    struct Symbol *s = symbolTable;
    while(s) {
        if(strcmp(s->name, name) == 0)
            return;
        s = s->next;
    }
    s = (struct Symbol*) malloc(sizeof(struct Symbol));
    s->name = strdup(name);
    s->line = line;
    s->next = symbolTable;
    symbolTable = s;
}
%}

%%

"int"       { printf("(%d, KEYWORD, '%s')\n", yylineno, yytext); return INT; }
"float"     { printf("(%d, KEYWORD, '%s')\n", yylineno, yytext); return FLOAT; }
"if"        { printf("(%d, KEYWORD, '%s')\n", yylineno, yytext); return IF; }
"else"      { printf("(%d, KEYWORD, '%s')\n", yylineno, yytext); return ELSE; }
"for"       { printf("(%d, KEYWORD, '%s')\n", yylineno, yytext); return FOR; }
"void"      { printf("(%d, KEYWORD, '%s')\n", yylineno, yytext); return VOID; }
  
[0-9]+\.[0-9]+   { printf("(%d, NUM_FLOAT, '%s')\n", yylineno, yytext); yylval.f_val = atof(yytext); return FLOAT_NUM; }
[0-9]+           { printf("(%d, NUM_INT, '%s')\n", yylineno, yytext); yylval.i_val = atoi(yytext); return INT_NUM; }
  
[a-zA-Z_][a-zA-Z0-9_]*  { 
                        printf("(%d, IDENTIFIER, '%s')\n", yylineno, yytext); 
                        addSymbol(yytext, yylineno);
                        return ID; 
                      }
  
"="        { printf("(%d, ASSIGN, '%s')\n", yylineno, yytext); return '='; }
";"        { printf("(%d, SEMICOLON, '%s')\n", yylineno, yytext); return ';'; }
"("        { printf("(%d, OPEN_PAREN, '%s')\n", yylineno, yytext); return '('; }
")"        { printf("(%d, CLOSE_PAREN, '%s')\n", yylineno, yytext); return ')'; }
"{"        { printf("(%d, OPEN_BRACE, '%s')\n", yylineno, yytext); return '{'; }
"}"        { printf("(%d, CLOSE_BRACE, '%s')\n", yylineno, yytext); return '}'; }
"+"        { printf("(%d, '+', '%s')\n", yylineno, yytext); return '+'; }
"-"        { printf("(%d, '-', '%s')\n", yylineno, yytext); return '-'; }
"*"        { printf("(%d, ERROR, '%s')\n", yylineno, yytext); return '*'; }
"/"        { printf("(%d, ERROR, '%s')\n", yylineno, yytext); return '/'; }
"%"        { printf("(%d, '%s', '%s')\n", yylineno, "MOD", yytext); return '%'; }
  
[ \t\n]+  { /* ...ignorar espaços em branco... */ }
.         { printf("(%d, ERROR, '%s')\n", yylineno, yytext); }
%%

int yywrap(void) {
    if(symbolTable) {
        printf("\nSymbol Table:\n--------------\n");
        struct Symbol *s = symbolTable;
        while(s) {
            printf("Name: %s, Line: %d\n", s->name, s->line);
            s = s->next;
        }
    }
    return 1;
}
