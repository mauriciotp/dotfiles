---
description: Roda os testes do pacote de um arquivo e corrige as falhas
argument-hint: <arquivo>
---
Rode os testes do pacote/módulo que contém o arquivo `$ARGUMENTS` (se vazio, use o projeto inteiro).

1. Descubra o comando de teste do projeto (Makefile, package.json, go.mod, Cargo.toml, pyproject etc.) e rode só o escopo desse pacote, não a suíte inteira.
2. Se tudo passar, diga isso em uma linha e pare.
3. Se algo falhar, ache a causa e corrija o código de produção. Só mude o teste se ele próprio estiver errado e diga por quê.
4. Rode os testes de novo até passarem e resuma o que mudou.
