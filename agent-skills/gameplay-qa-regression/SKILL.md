---
name: gameplay-qa-regression
description: Roda e amplia os testes do Nebulance (headless) e a matriz TC-001..040 apos cada mudanca de sistema.
---
1. Importar: Godot --headless --path . --import.
2. Rodar: Godot --headless --path . --script res://tests/run_tests.gd; codigo de saida 0 somente se tudo passar.
3. Para cada bug: escrever teste que falha, corrigir a causa, reexecutar o teste e a regressao.
4. Nunca enfraquecer, pular ou apagar teste para passar; falha preexistente e relatada a parte.
5. Atualizar status dos TC em docs/QA_PLAN.md com evidencia (comando e saida).
