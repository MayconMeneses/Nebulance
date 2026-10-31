# CONTROLS (provisório; confirmar após playtest — PDF §05)

| Ação (InputMap) | Teclado | Gamepad |
|---|---|---|
| move_left / move_right | A / D ou setas | direcional ou analógico esquerdo |
| jump | Espaço | botão inferior |
| special (habilidade) | Shift | botão lateral (X) |
| swap_prev / swap_next | Q / R | LB / RB |
| interact | E | botão superior (Y) |
| pause | Esc | Start |

No menu: setas / direcional movem o foco; Enter / botão inferior confirmam (ações ui_* padrão). Itens desativados não recebem foco.

Conflito resolvido provisoriamente: o PDF dá Q/E para troca e E para interagir; usamos Q/R para troca (ADR-0003).
Gamepad: mapeado no InputMap, NÃO testado com controle físico (NOT_RUN). Remapeamento de teclado: Opcoes > TECLAS (clique na acao e aperte a nova tecla; Esc cancela; "Restaurar teclas padrao"). Tecla ja usada por outra acao (inclusive as setas padrao) e recusada com mensagem. Salvo em `settings.json` (`keys`), separado do save. Gamepad nao e remapeavel nesta versao.
O código lê somente ações; nenhuma tecla física é usada na lógica.
