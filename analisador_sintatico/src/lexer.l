digit[0-9]
letter[a-zA-Z]
ID[a-zA-Z][a-zA-Z0-9]*
WHITESPACE[ ]
quebra[\n]
TAB[\t]
str\"([^"\\]|\\.)*\"


%{
    // Modified YY_DECL for C compilation
    #define YY_DECL int yylex()
    #include <string.h> // Changed from <string> to <string.h>
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
%option yylineno noyywrap
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
        add_to_symbol_table(yytext, yylineno);
        fprintf(out,"<ID,%d>\n",getId(yytext));
        }
{str}+ {fprintf(out, "<str,%s>\n", yytext);}
. {fprintf(out,"<%d,ERROR,\"%s\">\n" ,yylineno ,yytext); return 0;}

%%

/* Removed main() and auxiliary definitions (e.g. yywrap) to avoid multiple definitions */