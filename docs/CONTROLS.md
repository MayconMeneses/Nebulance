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

## Controles de toque (PC testado; aparelho real NOT_RUN)
Camada `TouchControls` (game/ui): um botao por acao do InputMap (andar <, >; PULAR; HAB.; INTERAGIR; HEROI -/+; pausa), aperta e solta a acao, entao a logica de jogo nao muda.
Multitoque (cada dedo segura o seu botao), deslizar entre botoes troca a acao, dois dedos no mesmo botao so soltam ao soltar o ultimo; fechar a fase solta tudo.
Configuracoes: Mostrar (Automatico = so em aparelho com tela de toque / Sempre / Nunca), Tamanho (Pequeno/Medio/Grande, menor botao >= 48 px), Opacidade (Baixa/Media/Alta), modo canhoto.
Menus: os botoes do Godot respondem ao toque (mouse emulado), ja funciona.
Pendente: textos "Pressione E" do HUD ainda citam o teclado; entrega de evento pelo motor so verificavel numa janela real; exportacao Android (SDK/JDK/keystore) nao feita; desempenho em celular desconhecido.
