# RELATORIO - FASE 7 / Campanha completa em graybox (42 fases)
Data: 2026-11-03 | Base: `main` `89e5d90` | Revisao SO de documentacao (nenhum codigo ou teste alterado).
Regressao completa informada nos commits de merge: **792 checagens, 0 falhas** (nao reexecutada por mim nesta revisao; ver procedencia em `docs/QA_PLAN.md`).

## O que e e o que NAO e
**E**: as 42 fases do catalogo (36 principais + S01..S06) existem em `game/levels/`, estao registradas em `LevelCatalog`, e cada uma tem um bot (`tests/support/level_bot_*.gd`) que a completa sem teleporte, mais uma suite automatizada. Os 6 chefes (Vyrkan, Zythra, Ferrorraiz, Thalassa, Zefrion, Necryon) seguem o mesmo contrato: 3 etapas com mecanismo proprio, avisos >= 0,6 s, so a faixa ativa fere, Golpe Triade com 3 herois diferentes, semente como transacao unica, reacao de Caeldron 1x, reinicio deterministico, chefe nao ressuscita.
**NAO e**: um jogo pronto nem validado por humanos. Tudo e **graybox** (caixas coloridas, visual e audio provisorios). Nenhuma fase passou por playtest; duracao, ritmo e dificuldade nao foram calibrados. Nao ha final, cutscene de libertacao, restauracao visual de planetas, loja nem cosmeticos equipaveis. Umbraxis ainda nao e jogavel no mapa. 60 FPS em hardware-alvo NAO foi validado.

## Tabela das 42 fases
"Moedas/segredos" vem das definicoes `.tres` (itens unicos / memorias / resgates). "Suite" e a suite principal; "bot" e a classe que completa a fase. Todas as linhas: bot completa sem teleporte = PASS na regressao informada; sem playtest humano.

| Fase | Nome | Suite | Bot | Moedas | Segredos (item/mem/resgate) | Graybox / desvio do design |
|---|---|---|---|---|---|---|
| 01 | O Primeiro Passo | suite_level, suite_level_bot, suite_flow | LevelBot | 9 | 1/1/0 | corte de vertical slice; torre de simbolo e so decoracao; sinalizacao do segredo por texto/icone ausente |
| 02 | A Ponte Desaparecida | suite_level_02 | LevelBot02 | 9 | 1/1/0 | atalho lateral de Pipa nao feito |
| 03 | Segredos da Floresta | suite_level_03 | LevelBot03 | 9 | 0/1/0 | portal para S01 |
| S01 | O Jardim Alem do Portal | suite_level_03 | LevelBotS01 | 4 | 2/0/0 | gravidade 0,4 e plataformas de ruptura |
| 04 | O Rio Luminoso | suite_level_04 | LevelBot04 | 9 | 0/0/1 | vento nao usado; pista visual pos-restauracao ausente |
| 05 | A Torre Esquecida | suite_level_05 | LevelBot05 | 9 | 0/1/0 | holograma sem texto/imagem; bau sem tabela "especial" |
| 06 | O Guardiao das Raizes (Vyrkan) | suite_boss | LevelBot06 | 6 | 0/0/0 | so erupcoes de raizes; sem cutscene de libertacao; sem compartimento selado da Astralis |
| 07 | O Despertar dos Cristais | suite_cristalia_07 | LevelBot07 | 9 | 1/0/0 | feixes/prismas deterministicos |
| 08 | O Labirinto dos Reflexos | suite_cristalia_08 | LevelBot08 | 9 | 1/0/0 | planeio de Pipa ate o dispositivo |
| 09 | O Jardim das Orquideas | suite_cristalia_09 | LevelBot09 | 9 | 0/1/0 | portal para S02 |
| 10 | O Trem de Luz | suite_cristalia_10 | LevelBot04 | 9 | 1/0/1 | bot compartilhado com a fase 04 |
| 11 | A Catedral Prismatica | suite_cristalia_11 | LevelBot11 | 9 | 0/1/0 | sem texto/imagem do arquivo |
| 12 | Zythra, a Orquidea de Cristal (chefe) | suite_boss_zythra | LevelBot12 | 6 | 0/0/0 | ilusoes so como flor real x falsas; sem petalas/projeteis alem das faixas |
| S02 | Camara das Frequencias Perdidas | suite_cristalia_09 | LevelBotS02 | 4 | 2/0/0 | sequencia de 4 cristais musicais |
| 13 | O Porto das Engrenagens | suite_mecatron_13 | LevelBot13 | 9 | 1/0/0 | esteiras + elevador de polaridade |
| 14 | As Esteiras de Titanio | suite_mecatron_14 | LevelBot14 | 9 | 1/0/0 | 3 prensas deterministicas |
| 15 | O Trem do Eclipse | suite_mecatron_15 | LevelBot04 | 9 | 1/0/1 | reaproveita a geometria da fase 10; acessorio **nao** esta num vagao elevado |
| 16 | O Labirinto Magnetico | suite_mecatron_16 | LevelBot16 | 9 | 1/1/0 | so polaridade de plataformas (sem magnetismo como forca); a Oficina Zero nao tem portal aqui |
| 17 | A Forja Autonoma | suite_mecatron_17 | LevelBot17 | 9 | 1/1/0 | portal para S03 aberto por painel escondido |
| 18 | Ferrorraiz, o Cacto Mecanico (chefe) | suite_boss_ferrorraiz | LevelBot18 | 6 | 0/0/0 | sem bracos/espinhos/campo magnetico |
| S03 | Oficina Zero | suite_mecatron_s03 | LevelBotS03 | 4 | 1/1/0 | elevador + trilho compactos |
| 19 | A Costa das Luzes | suite_aquarys_19 | LevelBot19 | 9 | 1/0/0 | nivel de agua discreto, sem fisica de fluidos |
| 20 | Os Canais Suspensos | suite_aquarys_20 | LevelBot20 | 9 | 1/0/0 | barreira de Rocco + escalada de Zuri |
| 21 | Os Recifes Esquecidos | suite_aquarys_21 | LevelBot21 | 9 | 0/1/0 | "plataforma transparente" reaproveita `RupturePlatform`; portal para S04 |
| 22 | A Onda Colossal | suite_aquarys_22 | LevelBot22 | 9 | 0/0/1 | a onda e uma `ChaseWave` sem agua visual |
| 23 | O Templo das Mares | suite_aquarys_23 | LevelBot23 | 9 | 0/1/0 | dois reservatorios + fluxo; "entrada de Thalassa" e um arco decorativo |
| 24 | Thalassa, a Vitoria-Regia (chefe) | suite_aquarys_24 | LevelBot24 | 6 | 0/0/0 | sem ataques alem das faixas; sem cutscene |
| S04 | Oceano Esquecido | suite_aquarys_s04 | LevelBotS04 | 9 | 1/1/0 | comporta + 3 plataformas flutuantes + degraus de metal (sem arte de instalacao subaquatica) |
| 25 | O Porto das Nuvens | suite_aerion_25 | LevelBot25 | 9 | 1/0/0 | item Horizonte fica **na rota**; sem vento visivel |
| 26 | Os Jardins Suspensos | suite_aerion_26 | LevelBot26 | 9 | 1/0/0 | **sem rota opcional nas nuvens** (so o item sob a estrutura) |
| 27 | Corredores do Vento | suite_aerion_27 | LevelBot27 | 9 | 0/1/0 | **revelacao fraca**: a ilha oculta aparece quando o painel liga, e o painel ja e obrigatorio |
| 28 | O Ceu de Cabeca para Baixo | suite_aerion_28 | LevelBot28 | 9 | 1/0/0 | **teto como deslizamento**: o heroi sobe e desliza pelo teto, nao anda nele como piso |
| 29 | O Observatorio Celestial | suite_aerion_29 | LevelBot29 | 9 | 1/1/0 | console libera a ponte; previa de Umbraxis e item + decoracao |
| 30 | Zefrion, o Dente-de-Leao (chefe) | suite_boss_zefrion | LevelBot30 | 6 | 0/0/0 | gravidade localizada = zona de 0,6 em volta do nucleo (efeito leve) |
| S05 | Jardim Sem Gravidade | suite_aerion_s05 | LevelBotS05 | 5 | 1/1/0 | portal na **ultima ilha da fase 28**, nao "entre duas ilhas" |
| 31 | O Limiar das Raizes | suite_umbraxis_31 | LevelBot31 | 9 | 1/0/0 | raizes e olho de Caeldron so decoracao |
| 32 | As Fases Quebradas | suite_umbraxis_32 | LevelBot32 | 9 | 0/1/0 | **sem atalho dimensional**; 5 modulos na mesma cena (sem descarregar mundos) |
| 33 | O Jardim dos Ecos | suite_umbraxis_33 | LevelBot33 | 9 | 1/1/0 | projecoes da tripulacao so decoracao; portal para S06 |
| 34 | A Estrada para o Coracao | suite_umbraxis_34 | LevelBot34 | 9 | 0/0/1 | espelho de cosmeticos e so decoracao (sem seletor) |
| 35 | A Ultima Mensagem | suite_umbraxis_35 | LevelBot35 | 9 | 0/1/0 | sintese das 5 mecanicas; "reduzir movimento" troca plataforma movel por ponte fixa |
| 36 | Necryon e a Ultima Semente (chefe) | suite_umbraxis_36 | LevelBot36 | 6 | 0/0/0 | **sem final**: so a semente e a mensagem de reacao de Caeldron |
| S06 | Camara da Primeira Expedicao | suite_umbraxis_s06 | LevelBotS06 | 9 | 1/1/0 | pedras-eco leves + fechadura final |

Contagem de chamadas `TestWorld.rec(` por suite de fase (estatica; nao e o numero de checagens executadas): Aerion 25: 8 · 26: 8 · 27: 11 · 28: 13 · 29: 10 · Zefrion: 20 · S05: 9 · Aquarys 19: 9 · 20: 7 · 21: 11 · 22: 8 · 23: 12 · 24: 18 · S04: 4 · Umbraxis 31: 6 · 32: 5 · 33: 10 · 34: 5 · 35: 8 · 36: 19 · S06: 5 · Mecatron 13: 10 · 14: 10 · 15: 9 · 16: 10 · 17: 7 · S03: 3 · Ferrorraiz: 17 · Cristalia 07: 6 · 08: 7 · 09: 13 · 10: 9 · 11: 9 · Zythra: 14 · Sylvara: level_02 15 · level_03 20 · level_04 9 · level_05 4 · boss 22.

## Pecas e mecanicas por planeta (resumo)
Sylvara: plataformas de ruptura/moveis, mecanismos e portao, onda de raizes, resgate, gravidade localizada. Cristalia: solver de feixes, prismas, cristais, portao de luz, sequencia de cristais. Mecatron: esteiras, prensas, polaridade (elevador/trilho), alavanca alternavel. Aquarys: `WaterBody` discreto, plataforma flutuante, passarela de mare, comporta, `TideFlux`. Aerion: `WindVent`, `ControlledPlatform`, vento horizontal no ar e gravidade invertida em zona (alterou `actor_controller.gd`). Umbraxis: `EchoStone`, modulos reutilizaveis dos planetas anteriores, `NecryonBoss`.

## Lista honesta de desvios fracos e pendencias
Desvios em relacao ao PDF, do mais ao menos visivel (todos documentados em `docs/LEVEL_BIBLE.md`):
1. **Sem final**: Necryon e a sexta semente existem, mas nao ha morte de Caeldron, cutscene de final nem pos-jogo (TC-035/036 NOT_RUN em `main` 89e5d90).
2. **Umbraxis nao jogavel no mapa** (`playable = false`), embora as 7 fases existam e passem nos testes.
3. **Fase 28**: o teto e um deslizamento sob gravidade invertida; o heroi nao anda no teto como piso, nao ha inversao de controles nem de camera.
4. **Fase 27**: a "corrente invertida" que revela a ilha oculta foi simplificada; a ilha aparece quando o painel liga (e o painel e obrigatorio), entao a revelacao e fraca.
5. **Fase 26**: nao ha a rota opcional nas nuvens; so o item sob a estrutura flutuante.
6. ~~Fase 25: item Horizonte na rota principal~~ **corrigido**: agora numa ilhota alta, so por Zuri (a rota principal termina a fase sem ele; teste).
7. **Fase 15**: acessorio nao esta num vagao elevado; geometria reaproveitada da fase 10.
8. **S05**: portal na ultima ilha da fase 28, nao "entre duas ilhas".
9. **Fases 21 e 22**: plataforma transparente = `RupturePlatform`; onda = `ChaseWave` sem agua visual. **Fase 23**: a "entrada de Thalassa" e um arco decorativo.
10. **Fase 30**: a gravidade localizada e uma zona de 0,6 em volta do nucleo, de efeito leve.
11. **Fase 32**: sem atalho dimensional; todos os modulos ficam na mesma cena (a regra de nao manter todos os mundos na memoria nao foi atendida de fato). **Fase 34**: sem seletor de cosmeticos.
12. **Chefes**: so faixas de erupcao como ataque; sem mordidas, espinhos, petalas/projeteis, campo magnetico; sem cutscene de libertacao; sem compartimento selado da Astralis (6 simbolos); sem restauracao visual do planeta.
13. **Ilusoes de Necryon** testadas por regra (evidencia pisca/forma); legibilidade para uma pessoa nao verificada.
14. **Sinalizacao de vento**: agora tem faixas de particulas (somem com a corrente desligada, respeitam perfil grafico e "reduzir movimento"; suite_wind_streaks). **Gravidade** invertida/baixa segue so por zona translucida colorida. Aparencia nao avaliada por pessoa.
15. **Rotulos "TC-04x/05x" duplicados** entre planetas nas suites (ver `docs/QA_PLAN.md`).
16. **`game_flow.gd` tem 319 linhas** (acima do limite de 200 do projeto); `actor_controller.gd` 198; `level_bot_umbraxis.gd` 265.
17. **Rede**: a consulta de atualizacao (ligada por padrao) contraria "sem rede" lido ao pe da letra.

Nao verificado: playtest humano de qualquer fase; gamepad fisico; toque em aparelho real e Android; FPS em hardware-alvo (e de qualquer fase alem da 01, em qualquer hardware); build exportado e instalador da versao atual; instalacao em maquina limpa; auditoria final de licencas e marca.
