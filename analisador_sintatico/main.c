#include <stdio.h>

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
    return 0;
}
