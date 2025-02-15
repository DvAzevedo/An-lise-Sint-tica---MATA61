#ifndef AST_H
#define AST_H

typedef struct ASTNode {
    char label[50];
    int num_children;
    struct ASTNode** children;
} ASTNode;

#endif
