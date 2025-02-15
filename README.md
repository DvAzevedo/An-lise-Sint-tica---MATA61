# Trabalho 2 - Análise Sintática

## MATA61 - Compiladores

### Introdução

Este trabalho consiste na criação de um analisador sintático utilizando Flex e Bison para uma linguagem de programação definida no Trabalho 1. A linguagem deve seguir as seguintes regras:

- Deve ser imperativa e compatível com o ASCII.
- Deve ser possível inicializar variáveis do tipo numérico (inteiro ou flutuante) com tipagem estática, além de vetores do tipo numérico.
- Deve ser possível fazer acessos e atribuições às variáveis inicializadas, incluindo os elementos individuais dos vetores. As atribuições devem ser expressões aritméticas que podem conter números pré-definidos e/ou variáveis e/ou funções.
- Deve ser possível criar desvios condicionais simples e compostos, com a condição sendo feita com uma operação de comparação.
- Deve ser possível criar um comando de repetição, com a condição para a repetição sendo feita com uma operação de comparação.
- Deve ser possível criar funções que, a partir de um número definido de parâmetros (com tipagem estática), retornem um número inteiro, ponto flutuante ou não retornem nada. O tipo de retorno deve ser explicitado na definição da função. Após a criação da função, é possível chamá-la no código.

### Estrutura do Analisador Sintático

#### Arquivo `parser.y`

O arquivo `parser.y` define a gramática da linguagem e as ações semânticas associadas. A seguir, apresentamos as principais regras de produção e suas justificativas.

#### Regras de Produção

1. **program**:
    ```yacc
    program:
        function_definition { root = $1; }
      | statement_list { root = $1; }
      ;
    ```
    - Justificativa: Define o ponto de entrada da gramática. Um programa pode ser uma definição de função ou uma lista de declarações.

2. **function_definition**:
    ```yacc
    function_definition:
        type ID '(' ')' compound_statement
          { $$ = createASTNode("function_definition", 3, createASTNode($1, 0), createASTNode($2, 0), $5); }
      ;
    ```
    - Justificativa: Permite a definição de funções com um tipo de retorno, um identificador e um corpo de função.

3. **statement_list**:
    ```yacc
    statement_list:
          statement_list statement { $$ = createASTNode("statement_list", 2, $1, $2); }
        | statement { $$ = createASTNode("statement_list", 1, $1); }
        ;
    ```
    - Justificativa: Permite a criação de uma lista de declarações, onde cada declaração pode ser uma das várias construções da linguagem.

4. **statement**:
    ```yacc
    statement:
          declaration
        | attribution
        | if_statement
        | while_statement
        | compound_statement
        | jump_statement
        ;
    ```
    - Justificativa: Define os diferentes tipos de declarações que podem ser feitas na linguagem.

5. **declaration**:
    ```yacc
    declaration:
          type ID ';' { $$ = createASTNode("declaration", 2, createASTNode($1, 0), createASTNode($2, 0)); }
        ;
    ```
    - Justificativa: Permite a declaração de variáveis com um tipo e um identificador.

6. **type**:
    ```yacc
    type:
          INT { $$ = "int"; }
        | FLOAT { $$ = "float"; }
        | VOID { $$ = "void"; }
        ;
    ```
    - Justificativa: Define os tipos de dados suportados pela linguagem.

7. **attribution**:
    ```yacc
    attribution:
          ID '=' expression ';' { $$ = createASTNode("attribution", 2, createASTNode($1, 0), $3); }
        ;
    ```
    - Justificativa: Permite a atribuição de valores a variáveis.

8. **if_statement**:
    ```yacc
    if_statement:
          IF '(' expression ')' statement %prec LOWER_THAN_ELSE { $$ = createASTNode("if_statement", 2, $3, $5); }
        | IF '(' expression ')' statement ELSE statement { $$ = createASTNode("if_statement", 3, $3, $5, $7); }
        ;
    ```
    - Justificativa: Permite a criação de estruturas condicionais simples e compostas.

9. **while_statement**:
    ```yacc
    while_statement:
          WHILE '(' expression ')' statement { $$ = createASTNode("while_statement", 2, $3, $5); }
        ;
    ```
    - Justificativa: Permite a criação de laços de repetição.

10. **compound_statement**:
    ```yacc
    compound_statement:
          '{' statement_list '}' { $$ = createASTNode("compound_statement", 1, $2); }
        ;
    ```
    - Justificativa: Permite a criação de blocos de código.

11. **jump_statement**:
    ```yacc
    jump_statement:
          RETURN expression ';' { $$ = createASTNode("return_statement", 1, $2); }
        | RETURN ';' { $$ = createASTNode("return_statement", 0); }
        ;
    ```
    - Justificativa: Permite a criação de declarações de retorno em funções.

12. **expression**:
    ```yacc
    expression:
          expression '+' expression { $$ = createASTNode("add", 2, $1, $3); }
        | expression '-' expression { $$ = createASTNode("sub", 2, $1, $3); }
        | expression '*' expression { $$ = createASTNode("mul", 2, $1, $3); }
        | expression '/' expression { $$ = createASTNode("div", 2, $1, $3); }
        | expression LE expression { $$ = createASTNode("le", 2, $1, $3); }
        | expression GE expression { $$ = createASTNode("ge", 2, $1, $3); }
        | expression EQ expression { $$ = createASTNode("eq", 2, $1, $3); }
        | expression NE expression { $$ = createASTNode("ne", 2, $1, $3); }
        | expression '<' expression { $$ = createASTNode("lt", 2, $1, $3); }
        | expression '>' expression { $$ = createASTNode("gt", 2, $1, $3); }
        | '(' expression ')' { $$ = $2; }
        | ID { $$ = createASTNode("ID", 1, createASTNode($1, 0)); }
        | INT_LITERAL { 
              char buffer[50];
              snprintf(buffer, sizeof(buffer), "%d", $1);
              $$ = createASTNode("INT_LITERAL", 1, createASTNode(buffer, 0)); 
          }
        | FLOAT_LITERAL { 
              char buffer[50];
              snprintf(buffer, sizeof(buffer), "%f", $1);
              $$ = createASTNode("FLOAT_LITERAL", 1, createASTNode(buffer, 0)); 
          }
        ;
    ```
    - Justificativa: Define as expressões aritméticas e relacionais suportadas pela linguagem.

### Integração com o Analisador Léxico

O analisador léxico (`scanner.l`) foi configurado para reconhecer os tokens definidos no `parser.y`. A integração entre o analisador léxico e o sintático foi feita de forma a garantir que os tokens sejam corretamente identificados e passados para o analisador sintático.

### Exemplo de Código e Árvore Sintática

O seguinte código:

```c
int main() {
    int x;
    x = 5;

    if (x < 3) {
        x = 1;
    } else {
        x = 0;
    }

    return 0;
}
```

Deve gerar uma árvore sintática similar à:

```
program
    function_definition
        int
        main
        compound_statement
            statement_list
                statement_list
                    statement_list
                        statement
                            declaration
                                int
                                x
                    statement
                        attribution
                            x
                            5
                statement
                    if_statement
                        condition
                            x
                            relop
                                <
                            3
                        statement_list
                            statement
                                attribution
                                    x
                                    1
                        statement_list
                            statement
                                attribution
                                    x
                                    0
                statement
                    return_statement
                        x
```

### Conclusão

O analisador sintático foi desenvolvido para reconhecer e construir a árvore sintática de programas escritos na linguagem definida. A integração entre o analisador léxico e sintático foi feita de forma a garantir a correta identificação e passagem de tokens. A documentação explica as regras de produção utilizadas e justifica suas escolhas, conforme solicitado na tarefa.
