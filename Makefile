# Variáveis de diretório e arquivos
SRC_DIR = analisador_sintatico
BISON_SRC = $(SRC_DIR)/parser.y
FLEX_SRC  = $(SRC_DIR)/scanner.l

BISON_OUT_C = $(SRC_DIR)/parser.tab.c
BISON_OUT_H = $(SRC_DIR)/parser.tab.h
FLEX_OUT    = $(SRC_DIR)/lex.yy.c

TARGET = analisador
CC = gcc
CFLAGS = -Wall

# Target final: gera o analisador compilado
all: $(TARGET)

$(TARGET): $(BISON_OUT_C) $(FLEX_OUT)
	$(CC) $(CFLAGS) -o $(TARGET) $(BISON_OUT_C) $(FLEX_OUT) -lfl

# Gera o arquivo parser.tab.c e parser.tab.h com o Bison
$(BISON_OUT_C) $(BISON_OUT_H): $(BISON_SRC)
	bison -d -o $(BISON_OUT_C) $(BISON_SRC)

# Gera o arquivo lex.yy.c com o Flex
$(FLEX_OUT): $(FLEX_SRC) $(BISON_OUT_H)
	flex -o $(FLEX_OUT) $(FLEX_SRC)

# Limpeza dos arquivos gerados
clean:
	rm -f $(TARGET) $(BISON_OUT_C) $(BISON_OUT_H) $(FLEX_OUT)
