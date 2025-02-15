# syntax-analysis-project/syntax-analysis-project/README.md

# Projeto de Análise Sintática

Este projeto implementa uma ferramenta de análise sintática utilizando Bison e Flex. Ele foi projetado para analisar uma linguagem de programação simples que inclui atribuições de variáveis e instruções condicionais.

## Estrutura do Projeto

- **src/main.c**: Contém a função principal e a lógica para atribuição de variáveis e instruções condicionais. Funciona como ponto de entrada da aplicação.
- **src/parser.y**: Define as regras gramaticais para a análise sintática usando Bison. Especifica como analisar a entrada com base na sintaxe definida.
- **src/lexer.l**: Contém as definições do analisador léxico utilizando Flex. Tokeniza a entrada para o parser, reconhecendo palavras-chave, identificadores e símbolos.
- **src/types/index.h**: Arquivo header que define os tipos e constantes usados em todo o projeto, incluindo as estruturas para tokens e resultados da análise.
- **Makefile**: Contém as instruções de compilação para o projeto, ligando os arquivos C com os arquivos gerados pelo Bison e Flex, e criando o executável.

## Instruções de Configuração

1. Verifique se você tem Bison e Flex instalados em seu sistema.
2. Clone o repositório ou baixe os arquivos do projeto.
3. Navegue até o diretório do projeto.

## Compilando o Projeto

Execute o comando a seguir para compilar o projeto:

```
make
```

Isto compilará os arquivos fonte e gerará o executável.

## Uso

Após a compilação, execute o executável para analisar o código de entrada. Forneça o código por meio da entrada padrão ou redirecione de um arquivo.

## Explicação dos Componentes

- **Bison**: Gerador de parser que converte as regras definidas em `parser.y` em um analisador.
- **Flex**: Gerador do analisador léxico responsável por tokenizar a entrada conforme definido em `lexer.l`.
- **Código em C**: A lógica principal é implementada em `main.c`, que interage com o parser e o lexer para realizar a análise sintática.

## Licença

Este projeto está licenciado sob a Licença MIT. Consulte o arquivo LICENSE para mais detalhes.