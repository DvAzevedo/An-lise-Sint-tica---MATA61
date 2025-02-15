typedef enum {
    TOKEN_INT,
    TOKEN_IF,
    TOKEN_ELSE,
    TOKEN_ASSIGN,
    TOKEN_LT,
    TOKEN_NUM,
    TOKEN_IDENTIFIER,
    TOKEN_SEMICOLON,
    TOKEN_EOF
} TokenType;

typedef struct {
    TokenType type;
    char *value;
} Token;

typedef struct {
    int result;
    int error;
} ParseResult;