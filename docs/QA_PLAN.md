# QA_PLAN — matriz TC-001..040 (PDF §18)

Estado revisado em 2026-11-03, sobre `main` no commit `89e5d90` (campanha de 42 fases em graybox). Comando de regressao:
`Godot --headless --path . --script res://tests/run_tests.gd` (ver README). Esta revisao e SO de documentacao: nenhum codigo ou teste foi alterado.

Estados: **PASS** = verificado por teste automatizado que passou · **PARCIAL** = parte coberta, parte NOT_RUN · **FAIL** = reprovado · **BLOCKED** = nao da para executar agora · **NOT_RUN** = nao executado (inclui tudo que exige humano ou hardware).
BLOCKED e NOT_RUN **nao** sao aprovacao.

## Procedencia dos numeros (leia antes de confiar)
- "Suite completa: 792 checagens, 0 falhas" e o resultado informado nos commits de merge da `main` (`89e5d90`, antes `dde9696`: 750, `ddfee9d`: 686). Eu NAO reexecutei a suite completa nesta revisao; reexecutei antes, no meu worktree, so as suites de Aerion (728 checagens na suite completa daquela data, 0 falhas, 0 erros de script).
- As contagens por suite no `docs/REPORTS/phase-07-campanha.md` sao chamadas estaticas de `TestWorld.rec(` no arquivo (uma chamada em laco conta uma vez), nao checagens executadas.
- Nenhum teste foi enfraquecido ou removido nesta revisao. Mutacoes ("mutacao -> FAIL") citadas sao as registradas nos relatorios antigos, nao refeitas agora.
- Em worktrees sem os assets reais (ponteiros Git LFS) os testes que instanciam herois geram `SCRIPT ERROR` ambiental; os numeros acima se referem a execucao com os assets reais.

## Matriz TC-001..040
| TC | Criterio (PDF) | Estado | Evidencia / limite |
|---|---|---|---|
| 001 | Abrir sem internet | PARCIAL | Build antigo (phase3) jogou a fase inteira com 0 conexoes. DESDE a v0.4.0 o jogo consulta `api.github.com` (GitHub Releases) ao abrir, **ligado por padrao** (`check_updates`, desligavel em Configuracoes; falha silenciosa; `suite_updates` garante que testes nao usam rede). Abrir sem internet NAO foi testado no build atual com rede bloqueada |
| 002 | Menu por teclado/controle e retomar | PARCIAL | `suite_flow` (foco por teclado, Continuar recupera o perfil). Gamepad fisico: NOT_RUN |
| 003 | Trocar heroi mantendo vidas/coracoes | PASS | `suite_swap` |
| 004 | Troca invalida sem softlock | PASS | `suite_swap` |
| 005 | Coyote time e jump buffer | PASS | `suite_controller` |
| 006 | Investida so em marcados | PASS | `suite_abilities` |
| 007 | Zuri salto duplo/escalada | PASS | `suite_abilities` |
| 008 | Pipa planeio limitado e vento | PASS | `suite_abilities` (e as fases com planeio: 05, 08, 22, 26, 27, 29, 30, S05) |
| 009 | Dano com invulnerabilidade | PASS | `suite_vitals` |
| 010 | 5 vidas e 3 coracoes (Aventura) | PASS | `suite_vitals` (3 perfis de dificuldade como dados). Selecao de dificuldade na interface: nao existe |
| 011 | Abismo consome 1 vida e reaparece | PASS | `suite_vitals`, `suite_level` e as suites de fase com queda (ex.: `suite_aerion_25`, `_28`) |
| 012 | Zerar vidas reinicia so a fase | PARCIAL | `suite_vitals`/`suite_level`: sinal de reinicio e reset da sessao e dos mecanismos. "Sem apagar progresso" depende de o perfil so ser gravado ao concluir (sem teste dedicado) |
| 013 | Checkpoint reverte estados de puzzle | PASS | `suite_level`, `suite_level_02`..`_04`, `suite_cristalia_07`/`_08`/`_10`/`_11`, `suite_mecatron_13`/`_15`, `suite_aquarys_22`/`_23`/`_24`, `suite_aerion_25`..`_30` (reinicio idempotente: agua, mecanismos, barreiras, chefes) |
| 014 | Portal leva ao segredo e volta sem duplicacao | PASS | `suite_level_03` (fluxo completo S01), `suite_cristalia_09` (S02), `suite_mecatron_17` (so abertura do portal e catalogo), `suite_aquarys_21`, `suite_aerion_28`/`suite_aerion_s05` (inclui ida e volta pelo fluxo), `suite_umbraxis_33`/`_s06`. A ida e volta pelo fluxo completo so foi exercitada em S01 e S05; nas demais o teste cobre a abertura e o catalogo |
| 015 | Bau de fase entrega recompensa | PASS | `suite_economy`, `suite_level`, `suite_flow` e o bot de cada fase (`best_grade_by_level`) |
| 016 | Bau repetido nao duplica | PASS | `suite_economy`, `suite_flow` |
| 017 | Bronze -> Ouro credita a diferenca | PASS | `suite_economy` |
| 018 | Loja recusa saldo insuficiente | NOT_RUN | loja nao existe no jogo |
| 019 | Cosmetico nao altera atributos | PASS | `suite_cosmetics`: vestir muda so a cor (velocidade, pulo e capsula iguais), por heroi, persiste no save e o espelho da fase 34 o seleciona; aparencia nao avaliada por pessoa |
| 020 | Salvar, fechar, reabrir | PASS | `suite_save`, `suite_flow` (inclui segundo processo que reabre o save) |
| 021 | Save invalido preserva backup | PASS | `suite_save`, `suite_flow`. Disco cheio/permissao: NOT_RUN |
| 022 | Trocar dificuldade sem perder campanha | NOT_RUN | sem selecao de dificuldade na interface |
| 023 | Reatribuicao de comandos e gamepad | PARCIAL | teclado: PASS em `suite_keybindings` (recusa conflito, restaurar padrao, salva em `settings.json`). Gamepad nao e remapeavel; gamepad fisico NOT_RUN |
| 024 | Reducao de tremor/flashes/legendas/contraste | PARCIAL | reduzir movimento e flashes: PASS (`suite_accessibility`, e a ponte fixa da fase 35). Legendas e contraste: NOT_RUN (o jogo nao tem dialogo falado) |
| 025 | Saltar cutscene mantem recompensa | PARCIAL | introducao da Astralis e reacao de Caeldron pulaveis, sem conceder nem perder nada (`suite_flow`). Outras cutscenes (libertacao, final) nao existem |
| 026 | Mapa so mostra rotas disponiveis | PARCIAL | `suite_galaxy`, `suite_boss`: estados derivados do save, raizes, contagem de segredos sem spoiler, modo QA. Umbraxis (indice 5) ainda `playable = false`; viagens da Astralis reduzidas a chegada 3D pulavel |
| 027 | Semente destruida: Caeldron reage 1x | PASS | `suite_boss`, `suite_boss_zythra`, `suite_boss_ferrorraiz`, `suite_aquarys_24`, `suite_boss_zefrion`, `suite_umbraxis_36` (transacao unica, salva na hora; reacao so em `first_time`) |
| 028 | Semente restaura planeta e liberta guardiao | PARCIAL | estado no save e no mapa (raiz removida, proximo planeta aberto, guardiao em `boss_freed_ids`, arena reabre restaurada, chefe nao ressuscita): PASS nas mesmas suites. **Restauracao visual do planeta e cutscene de libertacao: nao implementadas** |
| 029 | Vyrkan: padroes, telegraph, sem armas | PASS | `suite_boss` (aviso >= 0,6 s, so a faixa ativa fere, etapas na ordem certa, Golpe Triade com 3 herois diferentes). O mesmo contrato e testado nos outros 5 chefes |
| 030 | Zythra: prismas e luz deterministicos | PASS | `suite_beams` (solver), `suite_boss_zythra` |
| 031 | Ferrorraiz: magnetismo e maquinas consistentes | PARCIAL | maquinas, esteiras, prensas e polaridade deterministicas: PASS (`suite_mecatron_13`..`_17`, `suite_boss_ferrorraiz`). Magnetismo **como forca** nao existe (so polaridade de plataformas) |
| 032 | Thalassa: mares e comportas reproduziveis | PASS | `suite_aquarys_19`..`_24`, `suite_aquarys_s04` (nivel discreto, restauracao deterministica no checkpoint). Sem fisica de fluidos por projeto |
| 033 | Zefrion: vento e gravidade local sinalizados | PARCIAL | vento horizontal/vertical e gravidade reduzida/invertida testados (`suite_aerion_25`..`_30`, `suite_aerion_s05`); a sinalizacao do vento tem faixas de particulas (`suite_wind_streaks`) e a gravidade e uma zona translucida com cor; **sem teste de legibilidade com humano** |
| 034 | Necryon: ilusoes distinguiveis por evidencias | PASS | `suite_umbraxis_33`, `suite_umbraxis_36` (pedra-eco real vs ilusoes por evidencia: pisca ou forma; erro = -1 coracao). "Distinguivel para uma pessoa" e playtest: NOT_RUN. Analogo anterior em `suite_boss_zythra` |
| 035 | Sexta semente: morte definitiva de Caeldron | NOT_RUN | `suite_umbraxis_36` testa a semente de Umbraxis e a mensagem de reacao; **nao ha cena de final nem morte de Caeldron em `main` 89e5d90**. Se outro trabalho (final/fluxo) entrar, reavaliar |
| 036 | Pos-final: planetas revisaveis sem reviver o vilao | NOT_RUN | depende do final (acima); nao verificado |
| 037 | Exportar Windows e iniciar fora do editor | PARCIAL | exportacao antiga (`build/nebulance_phase3.exe`) rodou e o bot completou a fase 01. Build da versao atual (0.4.0, 42 fases) NAO exportado/validado nesta revisao; maquina limpa: NOT_RUN |
| 038 | Export sem rede/IA/MCP | PARCIAL | sem IA/MCP no jogo. A consulta de atualizacao (ligada por padrao) e o unico uso de rede; `tests/` ainda vai no pacote (gancho `--bench`). Inventario final do pacote: pendente |
| 039 | Perfil grafico baixo/medio/alto sem quebra | PARCIAL | perfis Baixo/Medio/Alto existem; `suite_settings` e o bot da fase 01 completam nos tres no build antigo. Desempenho: ver benchmark abaixo (60 FPS NAO validado) |
| 040 | Auditoria de licencas e procedencia | PARCIAL | `docs/ASSET_LICENSES.md` cobre assets de teste e audio gerado; modelos 3D e audio sao de primeira passagem. Marca/nome comercial NAO pesquisados |

Contagem dos 40 TC: PASS 21 (003–011, 013–017, 020, 021, 027, 029, 030, 032, 034) · PARCIAL 14 (001, 002, 012, 023–026, 028, 031, 033, 037–040) · NOT_RUN 5 (018, 019, 022, 035, 036) · FAIL 0 · BLOCKED 0. "PASS" vale so para o que o teste automatizado cobre (ver a coluna de evidencia). Playtest humano, gamepad fisico, toque em aparelho real, Android, FPS em hardware-alvo e maquina limpa: NOT_RUN.

## IDs de teste internos (TC-041 em diante)
O PDF so define TC-001..040. As suites de fase usam rotulos internos "TC-0xx" acima de 040 para agrupar checagens. **Cada rotulo interno pertence a uma unica suite** (renumerados em 2026-11: antes o mesmo numero era reutilizado por planetas diferentes, e TC-040 em `suite_mecatron_13` colidia com a auditoria de licencas do PDF). Rotulo novo: usar o proximo numero livre (hoje TC-065). Mapa como esta no codigo:
| Rotulo | Suite |
|---|---|
| TC-041, TC-058 | `suite_mecatron_13` |
| TC-042 | `suite_mecatron_14` |
| TC-043 | `suite_mecatron_16` |
| TC-044 | `suite_mecatron_17` |
| TC-045 | `suite_aquarys_19` |
| TC-046 | `suite_aquarys_20` |
| TC-059 | `suite_aquarys_21` |
| TC-047 | `suite_aquarys_23` |
| TC-048, TC-049 | `suite_aquarys_24` |
| TC-050 | `suite_aerion_25` |
| TC-051 | `suite_aerion_26` |
| TC-052 | `suite_aerion_27` |
| TC-053, TC-057 | `suite_aerion_28` |
| TC-054 | `suite_aerion_29` |
| TC-055, TC-056 | `suite_boss_zefrion` |
| TC-061 | `suite_umbraxis_32` |
| TC-060 | `suite_umbraxis_33` |
| TC-062 | `suite_umbraxis_36` |
| TC-063 | `suite_ending` |
| TC-064 | `suite_astralis_vault` |

## Benchmark historico (NAO e o hardware-alvo; NAO prova 60 FPS)
Medido antes da campanha completa, bot jogando a fase 01 com HUD e audio, Intel UHD 620, `gl_compatibility`:
- build exportado: 1086 quadros, media 59,0 FPS, 1% low 59,5 FPS, pior quadro 145,4 ms (travamento unico aparente);
- projeto no editor: 1070 quadros, media 58,2 FPS, 1% low 48,3 FPS, pior quadro 141,8 ms.

| Perfil | Com vsync: media / 1% low | Sem vsync: media / 1% low |
|---|---|---|
| Baixo | 57,5 / 45,2 | 137,7 / 94,0 |
| Medio | 58,0 / 40,1 | 69,3 / 57,3 |
| Alto | 54,9 / 38,0 | 70,6 / 51,4 |
Pior quadro ~145-150 ms (provavel compilacao de shaders; cache frio/quente nao separados). 60 FPS estaveis NAO foram atingidos em Medio/Alto com vsync nessa maquina. Nenhuma fase posterior a 05 foi medida.

## Nao verificado (resumo)
Playtest humano de qualquer fase (diversao, dificuldade, duracao, legibilidade); gamepad fisico; controles de toque em aparelho real e Android (a camada de toque e testada so em PC por `suite_touch`); FPS em hardware-alvo; instalacao em maquina limpa e com rede bloqueada; instalador `installer/nebulance.iss` compilado/executado; loja, cosmeticos equipaveis, selecao de dificuldade, final e pos-jogo; restauracao visual dos planetas.
