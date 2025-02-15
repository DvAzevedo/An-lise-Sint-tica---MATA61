%{
#include "ast.h"           // Inclui a definição de ASTNode
#include "parser.tab.h"
#define YY_DECL extern int yylex()
#include <string.h>
#include <stdlib.h>         // Em vez de <cstdlib>
#include <stdio.h>          // Em vez de <cstdio>
extern void yyerror(const char *s);   // <-- Adicionado

/* Variáveis auxiliares */
int linha = 1;

/* Mantém a tabela de símbolos se necessário */
typedef struct {
    char name[50];
    int id;
    int line;
} Symbol;

Symbol symbol_table[100];
int symbol_count = 0;

void add_to_symbol_table(const char *name, int line) {
    if (symbol_count >= 100) {
        fprintf(stderr, "Erro: Tabela de símbolos cheia.\n");
        return;
    }
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return;
        }
    }
    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].line = line;
    symbol_table[symbol_count].id = symbol_count;
    symbol_count++;
}

int getId (const char *name){
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

/* Impressão da tabela de símbolos */
void print_symbol_table() {
    printf("\nSymbol Table:\n");
    printf("--------------\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("Name: %s, Id: %d\n", symbol_table[i].name, symbol_table[i].id);
    }
}
%}

/* Definições de expressões regulares */
digit      [0-9]
letter     [a-zA-Z]
ID         [a-zA-Z][a-zA-Z0-9]*
WHITESPACE [ ]
quebra     [\n]
TAB        [\t]
CR         [\r]
str        \"([^"\\]|\\.)*\"

%option noyywrap
%x COMMENT

%%

{CR}                    { /* Ignora retorno de carro */ }  // <-- Adicionado
{quebra}                { /* Atualiza a linha se necessário */ }
"//".*                  { /* Ignora comentários de linha única */ }

"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL); }
<COMMENT>(.|\n)+        { /* Ignora o conteúdo do comentário */ }
<COMMENT><<EOF>>        { yyerror("Comentário não terminado"); }

 /* Palavras reservadas (note que devem vir ANTES da regra de ID) */
float                   { return FLOAT; }
else                    { return ELSE; }
if                      { return IF; }
int                     { return INT; }
return                  { return RETURN; }
void                    { return VOID; }
while                   { return WHILE; }

 /* Operadores e símbolos */
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"<="                    { return LE; }
">="                    { return GE; }
"=="                    { return EQ; }
"!="                    { return NE; }
"<"                     { return '<'; }
">"                     { return '>'; }
"="                     { return '='; }
";"                     { return ';'; }
","                     { return ','; }
"("                     { return '('; }
")"                     { return ')'; }
"["                     { return '['; }
"]"                     { return ']'; }
"{"                     { return '{'; }
"}"                     { return '}' ;}

 /* Literais numéricos */
{digit}+("."{digit}+)    { 
                            /* Supondo que o parser espera um FLOAT_LITERAL com valor numérico */
                            yylval.floatval = atof(yytext); 
                            return FLOAT_LITERAL;
                         }
{digit}+                { 
                            yylval.intval = atoi(yytext); 
                            return INT_LITERAL;
                         }

 /* Regra para tokens malformados (exemplo: 123abc) */
{digit}+{ID}+          { yyerror("Token malformado"); }

 /* Identificadores */
{ID}                   { 
                            yylval.str = strdup(yytext);
                            add_to_symbol_table(yytext, yylineno);
                            return ID;
                         }

 /* Literais do tipo string */
{str}                  { 
                            yylval.str = strdup(yytext);
                            return STR;
                         }

{WHITESPACE}+|{TAB}+    { /* Ignora espaços e tabulações */ }

.                      { yyerror("Caractere inválido"); }

%%
