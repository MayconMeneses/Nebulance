---
name: game-production-orchestrator
description: Abre e fecha cada marco do Nebulance com plano, gate, riscos e relatorio real; usar no inicio e fim de toda fase.
---
1. Ler docs/REQUIREMENTS_MATRIX.md e o ultimo docs/REPORTS/phase-XX.md.
2. Listar o escopo do marco (IDs RF/RNF/TC) e o gate do PDF para avancar.
3. Executar em passos pequenos; nao marcar nada como pronto sem teste rodado.
4. Resultado de cada gate: PASS, FAIL, BLOCKED ou NOT_RUN (BLOCKED/NOT_RUN nao aprovam).
5. Ao fechar: atualizar a matriz, escrever docs/REPORTS/phase-XX.md no formato do PDF secao 20 e commitar.
