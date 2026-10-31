# ADR-0003 — Conflito de teclas: trocar personagem vs. interagir

Status: proposto, aguarda confirmação do dono/playtest (PDF diz "confirmar após playtest").
Problema: a tabela de controles do PDF (§05) dá "Trocar personagem = Q/E" e "Interagir = E". A tecla E fica duplicada.
Solução aplicada no InputMap provisório: `swap_prev` = Q, `swap_next` = R, `interact` = E. Gamepad: LB/RB para troca, Y para interagir.
Impacto: apenas bindings no `project.godot`; nenhum código lê tecla física (testes verificam as ações). Fácil de reverter.
