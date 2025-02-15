#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

ASTNode* create_node(ASTNodeType type, const char* value, int line) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type;
    node->value = strdup(value);
    node->line = line;
    node->child_count = 0;
    node->children = NULL;
    return node;
}

void add_child(ASTNode* parent, ASTNode* child) {
    parent->children = (ASTNode**)realloc(parent->children, sizeof(ASTNode*) * (parent->child_count + 1));
    parent->children[parent->child_count] = child;
    parent->child_count++;
}

void print_ast(ASTNode* node, int indent) {
    if(!node) return;
    for(int i=0; i<indent; i++) printf("  ");
    printf("Type: %d, Value: %s, Line: %d\n", node->type, node->value, node->line);
    for(int i=0; i<node->child_count; i++) {
        print_ast(node->children[i], indent + 1);
    }
}