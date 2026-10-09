-- Registro central dos prompts prontos: o ÚNICO lugar para criar ou editar um.
--
-- Cada item gera, automaticamente (ver claude/init.lua):
--   • o comando :ClaudeCode<name>, que aceita range (seleção visual ou :10,20)
--   • o atalho `key`, nos modos normal (linha do cursor) e visual (seleção)
--   • uma entrada no :ClaudeCodeSelect, com `desc` como título
--
-- `prompt` pode usar os placeholders de claude/context.lua (@this, @buffer,
-- @diagnostics…). Convenção dos atalhos: minúscula age sobre @this; a maiúscula
-- é a variante (ae explica o código, aE explica os diagnósticos).

---@class claude.Prompt
---@field name string sufixo do comando: "Explain" -> :ClaudeCodeExplain
---@field key string atalho
---@field desc string descrição (which-key e Select)
---@field prompt string texto enviado ao Claude, com placeholders

---@type claude.Prompt[]
return {
  {
    name = "Explain",
    key = "<leader>ae",
    desc = "Explain Code",
    prompt = "Explique @this e seu contexto: o que faz, por que provavelmente foi escrito assim e "
      .. "armadilhas. Sugira melhorias concretas, se houver, mas não altere nada.",
  },
  {
    name = "ExplainDiagnostics",
    key = "<leader>aE",
    desc = "Explain Diagnostics",
    prompt = "Explique a causa destes diagnósticos, sem alterar nada: @diagnostics",
  },
  {
    name = "Fix",
    key = "<leader>af",
    desc = "Fix Diagnostics",
    prompt = "Corrija estes diagnósticos, explicando a causa em poucas linhas. Se houver mais de "
      .. "uma correção razoável, aplique a mais simples e mencione a alternativa: @diagnostics",
  },
  {
    name = "Review",
    key = "<leader>ar",
    desc = "Review Code",
    prompt = "Revise @this quanto a corretude e legibilidade. Liste os problemas por gravidade, "
      .. "sem alterar nada.",
  },
  {
    name = "Document",
    key = "<leader>ad",
    desc = "Document Code",
    prompt = "Adicione comentários documentando @this, no estilo do restante do arquivo.",
  },
  {
    name = "Optimize",
    key = "<leader>ao",
    desc = "Optimize Code",
    prompt = "Otimize @this quanto a desempenho e legibilidade, sem mudar o comportamento.",
  },
  {
    name = "Implement",
    key = "<leader>ai",
    desc = "Implement Code",
    prompt = "Implemente @this.",
  },
  {
    name = "AddTests",
    key = "<leader>at",
    desc = "Add Tests",
    prompt = "Adicione testes para @this, seguindo o padrão de testes do projeto.",
  },
  {
    name = "RunTests",
    key = "<leader>aT",
    desc = "Run and Fix Tests",
    prompt = "Rode os testes do pacote que contém @buffer: descubra o comando de teste do projeto "
      .. "(Makefile, package.json, go.mod, Cargo.toml…) e rode só esse escopo. Se algo falhar, "
      .. "corrija o código de produção (o teste só se ele estiver errado, dizendo por quê) e "
      .. "rode de novo até passar.",
  },
}
