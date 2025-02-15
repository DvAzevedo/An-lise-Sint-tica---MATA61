digit[0-9]
letter[a-zA-Z]
ID[a-zA-Z][a-zA-Z0-9]*
WHITESPACE[ ]
quebra[\n]
TAB[\t]
str\"([^"\\]|\\.)*\"


%{
    #include "parser.tab.h"
    #define YY_DECL extern "C" int yylex()
    #include<string.h>
    #include<iostream>
    using namespace std;
    FILE *out ;
	int linha;

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

    void print_symbol_table() {
        fprintf(out, "\nSymbol Table:\n");
        fprintf(out, "--------------\n");
        for (int i = 0; i < symbol_count; i++) {
            fprintf(out, "Name: %s, Id: %d\n", symbol_table[i].name, symbol_table[i].id);
        }
    }
%}
%option yylineno
%x COMMENT

%%

{quebra}

"//".* { /* Ignora comentários de linha única */ }


"/*" { linha=yylineno; BEGIN(COMMENT); }

<COMMENT>"*/" { BEGIN(INITIAL); }

<COMMENT>(.|\n);

<COMMENT><<EOF>> {fprintf(out,"(%d,ERROR,\"/*\")\n",linha); return 0;}

float|else|if|int|return|void|while {fprintf(out,"<%s>\n" ,yytext);} 

"+"|"-"|"*"|"/"|"<"|"<="|">"|">="|"=="|"!="|"="|";"|","|"("|")"|"["|"]"|"{"|"}" {fprintf(out,"<%s>\n" ,yytext);}

{WHITESPACE}+|{quebra}|{TAB}+
 
{digit}+("."{digit}+) { fprintf(out, "<digitf, %s>\n", yytext);}

{digit}+ {fprintf(out,"<digit, %s>\n",yytext);}

{digit}+{ID}+ {fprintf(out,"<%d,ERROR,\"%s\">\n",yylineno,yytext); return 0;}

{ID}+ {
    yylval.str = strdup(yytext); // Copia o valor do token para yylval.str
    add_to_symbol_table(yytext, yylineno);
    fprintf(out, "<ID,%d>\n", getId(yytext));
    return ID;
}
{str}+ {fprintf(out, "<str,%s>\n", yytext);}
. {fprintf(out,"<%d,ERROR,\"%s\">\n" ,yylineno ,yytext); return 0;}

%%

int yywrap();

int main(int argc, char *argv[]) {
    FILE *arquivo = fopen(argv[1], "r");
    if (!arquivo) {
        cout << "Arquivo inexistente" << endl;
        return -1;
    }
    yyin = arquivo;
    out = fopen(argv[2], "w");
    if (!out) {
        cout << "Erro ao abrir arquivo de saída" << endl;
        return -1;
    }
    yylex();
    print_symbol_table();
    return 0;
}


int yywrap(){
    return 1;
}