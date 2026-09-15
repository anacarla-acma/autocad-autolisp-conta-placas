# AutoCAD AutoLISP - Contagem e Categorização Automática de Placas (CP)

![AutoLISP](https://img.shields.io/badge/Language-AutoLISP%20%2F%20Visual%20LISP-blue)
![AutoCAD](https://img.shields.io/badge/Platform-AutoCAD-red)
![License](https://img.shields.io/badge/License-MIT-green)

Rotina automatizada desenvolvida em **AutoLISP / Visual LISP (ActiveX)** para varrer o `Model Space` do AutoCAD, identificar blocos dinâmicos/estáticos de sinalização (bloco **"NP"**) e realizar a contagem quantitativa detalhada por tipo e por categoria operacional.

---

## 📌 Funcionalidades

- **Suporte a Blocos Dinâmicos:** Utiliza a propriedade `EffectiveName` para identificar corretamente o bloco `NP` mesmo se ele tiver sido transformado em bloco dinâmico e renomeado internamente pelo AutoCAD (ex: `*U123`).
- **Classificação Automática por Padrão de Rótulo:**
  - **EXISTENTE:** Rótulos no padrão `E + número` (ex: `E1`, `E2`, `E10`).
  - **A IMPLANTAR:** Rótulos compostos apenas por números (ex: `01`, `02`, `15`).
  - **A REMANEJAR:** Rótulos no padrão `RE + número` (ex: `RE1`, `RE2`).
  - **A RETIRAR:** Qualquer outro padrão de texto/letra (ex: `A`, `B`, `RET-01`).
- **Ordenação Natural (*Natural Sorting*):** Algoritmo customizado para ordenação alfanumérica correta no relatório da linha de comando (garante que `E2` venha antes de `E10`, e não ordenação alfabética estrita).

---

## 💻 Como Utilizar no AutoCAD

1. Faça o download do arquivo [`conta_placas.lsp`](./conta_placas.lsp).
2. No AutoCAD, digite o comando `APPLOAD` na linha de comando e pressione **Enter**.
3. Selecione o arquivo `conta_placas.lsp` e clique em **Load**.
4. No desenho desejado, digite a tecla de atalho **`CP`** na linha de comando e pressione **Enter**.
5. O resultado da contagem por categoria e o total geral serão exibidos diretamente no histórico da linha de comando (pressione `F2` no AutoCAD para visualizar em janela expandida).

---

## 📊 Exemplo de Saída no AutoCAD

```text
========== CONTAGEM DE PLACAS (bloco NP) ==========

EXISTENTES (E):
    E1: 4
    E2: 2
    >> TOTAL: 6

A RETIRAR:
    A: 1
    B: 3
    >> TOTAL: 4

A IMPLANTAR:
    01: 12
    02: 8
    >> TOTAL: 20

A REMANEJAR (RE):
    RE1: 2
    >> TOTAL: 2

====================================================
TOTAL GERAL DE PLACAS: 32
====================================================
