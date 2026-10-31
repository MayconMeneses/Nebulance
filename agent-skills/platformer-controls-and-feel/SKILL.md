---
name: platformer-controls-and-feel
description: Valida movimento, salto, coyote time, jump buffer, camera, colisao e troca dos tres herois; usar ao alterar gameplay.
---
1. Ler project.godot (InputMap) e docs/ADR/0003; nunca ler tecla fisica no codigo, so acoes.
2. Parametros (velocidade, gravidade, coyote, buffer) como @export ou Resource, nunca fixos no meio da logica.
3. Reproduzir o problema em tests/scenes/ antes de mexer; corrigir no menor modulo.
4. Rodar: Godot --headless --path . --script res://tests/run_tests.gd e depois playtest na janela.
5. Registrar parametros finais e resultado em docs/REPORTS/.
