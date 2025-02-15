#ifndef AST_H
#define AST_H

typedef enum {
    AST_NODE_PROGRAM,
    AST_NODE_STATEMENT,
    AST_NODE_DECLARATION,
    AST_NODE_TYPE,
    AST_NODE_ID,
    AST_NODE_ATTRIBUTION,
    AST_NODE_INT,
    AST_NODE_FLOAT,
    AST_NODE_IF,
    AST_NODE_CONDITION,
    AST_NODE_OPERATOR,
    AST_NODE_EXPRESSION
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    const char* value;
    int line;
    struct ASTNode** children;
    int child_count;
} ASTNode;

ASTNode* create_node(ASTNodeType type, const char* value, int line);
void add_child(ASTNode* parent, ASTNode* child);
void print_ast(ASTNode* node, int indent);

#endif
