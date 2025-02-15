CC = gcc
CFLAGS = -Wall -g -I./src
BISON = bison
FLEX = flex
BISONFLAGS = -d
LEXER = lex.yy.c
PARSER = parser.tab.c
PARSER_HEADER = parser.tab.h
OBJ = main.o $(PARSER) $(LEXER) ast.o

all: analise_sintatica

analise_sintatica: $(OBJ)
	$(CC) $(CFLAGS) -o analise_sintatica $(OBJ)

main.o: src/main.c src/types/index.h
	$(CC) $(CFLAGS) -c src/main.c

ast.o: src/ast.c
	$(CC) $(CFLAGS) -c src/ast.c

$(PARSER): src/parser.y
	$(BISON) $(BISONFLAGS) src/parser.y

$(LEXER): src/lexer.l $(PARSER_HEADER)
	$(FLEX) src/lexer.l

clean:
	rm -f $(OBJ) analise_sintatica $(LEXER) $(PARSER) $(PARSER_HEADER)