# LEVEL_BIBLE

Somente as fases já projetadas e implementadas. O catálogo completo (42 fases) está no PDF §10; nada foi inventado além dele.

## FASE 01 — O Primeiro Passo (Sylvara) — `sylvara_01`
Estado: IMPLEMENTADA em graybox colorido (visual provisório). Comprimento ≈ 106 m (a fase final do PDF pode ser mais longa; este é o corte do vertical slice). Bot completa a fase (ver QA_PLAN).

| Elemento do PDF | Implementação |
|---|---|
| Desembarque da Astralis; ensinar corrida, salto, troca e coleta | Plataforma de partida com Astralis provisória; degrau (salto); moedas; troca exigida no muro |
| Ponte simples | Ponte de madeira com tábua faltando sobre abismo (queda = 1 vida) |
| Barreira de impacto | Barreira laranja marcada (grupo `impact_target`) em x=40; só a investida de Rocco |
| Plataforma de Zuri | Muro de 3,0 m (x 52–56): só salto duplo de Zuri alcança o topo |
| Pipa alcança desvio com vento | Plataforma secreta a 9 m do topo do muro, coluna de vento no vão; planeio de Pipa (segredo) |
| Torre com símbolo dos exploradores (surpresa) | Torre violeta com símbolo ciano ao fundo (decoração; sem interação) |
| Criatura vegetal contaminada | `PatrolEnemy`: patrulha, telégrafo amarelo, investida; só fere em PATROL/LUNGE |
| Moedas, baú introdutório, segredo pequeno (acessório + símbolo do arquivo) | 9 moedas; baú `sylvara_01_chest`; item `sylvara_01_glow_scarf`; memória `archive_symbol_sylvara_01` |
| Um checkpoint após o ensino básico | `sylvara_01_cp1` em x=44 (depois da barreira) |
| Fim: baú registra recompensa | Baú em x=102; interagir (E) conclui, credita e salva |

Regra de desenho de 7 batidas: (1) introdução segura (área inicial); (2) desafio sem risco (degrau); (3) aplicação (ponte/barreira); (4) surpresa (muro exige troca, torre); (5) segredo sinalizado (plataforma elevada visível do muro, moedas guiam); (6) checkpoint antes do trecho longo; (7) baú final determinístico.

Playtest humano de "clara e divertida": NÃO realizado. Limitações: duração, ritmo e dificuldade não calibrados; sinalização do segredo por texto/ícone ausente; visual e áudio provisórios.

## FASE 02 — A Ponte Desaparecida (Sylvara) — `sylvara_02`
Estado: IMPLEMENTADA em graybox; bot completa (Ouro, 9/9 moedas, segredo, 0 vidas perdidas).
| Elemento do PDF | Implementacao |
|---|---|
| Plataformas com ruptura e sinalizacao solido/intangivel | `RupturePlatform` (3,0 s solida / 1,2 s intangivel; verde, ambar no aviso, roxo translucido sumida) |
| Sequencia sobre abismo | Primeira sequencia: 3 plataformas alternadas (introducao legivel) |
| Ativa estabilizador e escolhe rota | `Mechanism` na ilha central estabiliza as 4 plataformas da segunda sequencia (ou atravessar no tempo) |
| Primeiro indicio claro das raizes ligadas a semente | Raizes gigantes e brilhantes no fundo; memoria `memory_roots_clue_02` |
| Bau, moedas, segredo | Bau `sylvara_02_chest`; 9 moedas; item `sylvara_02_vine_charm` em plataforma alta (salto duplo de Zuri) |
| Checkpoint imediatamente antes da primeira sequencia longa | `sylvara_02_cp1` em x=14 |
Nao implementado: atalho lateral com Pipa ("possivel" no PDF).

## FASE 03 — Segredos da Floresta (Sylvara) — `sylvara_03`
Estado: IMPLEMENTADA em graybox; bot completa (inclui os 3 mecanismos e o portal).
| Elemento do PDF | Implementacao |
|---|---|
| Exploracao vertical, tres mecanismos antigos | Desafio OPCIONAL vertical: M1 atras da barreira (Rocco), M2 no alto (Zuri escala), M3 alem do vao com vento (Pipa planeia) |
| Ativacao abre a arvore; raizes abrem tunel com portal | `MechanismGate` abre quando os 3 estao ativos; libera o `Portal` para S01 |
| Portal para O Jardim Alem do Portal; bau e moedas | `sylvara_03_portal` -> `sylvara_s01`; bau `sylvara_03_chest`; 9 moedas; memoria `memory_portal_tree_03` no portal |
| Checkpoint antes do puzzle; retorno persistente | `sylvara_03_cp1` em x=16; retorno do portal preserva estado (testado) |

## S01 — O Jardim Alem do Portal (Sylvara, secreta) — `sylvara_s01`
Estado: IMPLEMENTADA em graybox; bot completa (4 moedas, 2 itens, 0 vidas perdidas).
Gravidade localizada baixa (0,4) e plataformas que se reorganizam (`RupturePlatform`). Recompensa: objeto da antiga expedicao (`sylvara_s01_expedition_relic`), acessorio (`sylvara_s01_leaf_crown`) e moedas. Retorno a fase de origem consistente; sem repeticao de itens unicos.


## FASE 04 — O Rio Luminoso (Sylvara) — `sylvara_04`
Estado: IMPLEMENTADA em graybox; bot completa (Ouro, 9/9 moedas, criatura resgatada, 0 vidas perdidas).
| Elemento do PDF | Implementacao |
|---|---|
| Travessia aquatica superficial por plataformas moveis e vento | 2 `MovingPlatform` deterministicas (vai e volta, 6 s) sobre o rio (queda = 1 vida); o bot espera os extremos. Vento NAO usado nesta fase |
| Raizes derrubam a ponte durante curta perseguicao | `ChaseWave` (3 m/s) comeca ao passar de x=64; um buraco de 2,5 m no caminho (a ponte derrubada); reinicia no checkpoint |
| Habitante de Sylvara em perigo e possibilidade de resgate | `Rescue` na ilha central; conta como segredo; registra em `story.rescued_creatures` |
| Bau; recompensa de resgate; pista visual de area pos-restauracao | Bau `sylvara_04_chest`. NAO implementada: pista visual de area pos-restauracao |
| Checkpoint antes da perseguicao; punicao justa por queda | `sylvara_04_cp1` em x=60 |

## FASE 05 — A Torre Esquecida (Sylvara) — `sylvara_05`
Estado: IMPLEMENTADA em graybox; bot completa (Ouro, 3 poderes em sequencia).
| Elemento do PDF | Implementacao |
|---|---|
| Combina habilidades e rupturas em instalacao antiga | Barreira (Rocco) -> torre de 5 m (Zuri escala) -> vao de 9 m com vento (Pipa planeia) -> ponte de 3 plataformas de ruptura |
| Holograma mostra a Astralis em expedicao anterior | Holograma ciano com memoria `memory_tower_hologram_05` (texto/imagem do holograma NAO implementados) |
| Bau especial, moedas, memoria parcial | Bau `sylvara_05_chest` (sem tabela "especial" propria ainda); 9 moedas |
| Checkpoint antes da sequencia dos tres poderes | `sylvara_05_cp1` em x=20 |

## FASE 06 — O Guardiao das Raizes (Sylvara) — `sylvara_06` (chefe Vyrkan)
Estado: IMPLEMENTADA em graybox; bot derrota o chefe e abre o bau (6 moedas, 0 vidas perdidas).
| Elemento do PDF (contrato de boss) | Implementacao |
|---|---|
| Tres momentos de complexidade crescente | 3 fases: 2, 3 e 4 faixas de erupcao por padrao; ciclos 2,7 / 2,35 / 2,1 s |
| Preparacao legivel antes de ataques | `RootLane`: aviso amarelo >= 0,7 s antes de ficar ativa (vermelha); testes exigem >= 0,6 s |
| Janela justa de reacao; sem overlap ambiguo | So a erupcao ATIVA fere; volume baixo (3 m): plataformas altas sao refugio; faixas separadas por vaos seguros |
| Rocco desloca suportes, Zuri aciona mecanismos altos, Pipa conduz vento | Etapa 1: apoio marcado (investida); etapa 2: mecanismo alto (escalada); etapa 3: mecanismo alto (planeio com vento) |
| Golpe Triade contextual | 3 pontos que exigem 3 herois DIFERENTES, qualquer ordem (o mesmo heroi nao basta) |
| Camera que enquadre o ponto vulneravel | Camera de arena fixa; `is_position_in_frustum` verificado para o bulbo, bordas e plataformas |
| Checkpoint pre-boss; transicao de libertacao | `sylvara_06_cp1`; libertacao do guardiao = estado do chefe/bau (visual provisorio; cutscene de libertacao NAO implementada) |
| Semente destruida uma vez; Caeldron reage uma vez; planeta restaurado; reliquia; rota Cristalia | Transacao `seed:sylvara` (`ProgressLedger`): grava semente, guardiao, `relic_sylvara` ("Reliquia de Sylvara", sem nome oficial no PDF) e `astralis_memory_sylvara`; salva na hora; reacao de Caeldron so se `first_time`; arena reabre restaurada; mapa: Sylvara Salvo, raiz removida, Cristalia Disponivel (mas em producao) |
Nao implementado: restauracao visual do planeta, cutscene de libertacao, compartimento selado da Astralis (6 simbolos), mordidas e armadilhas de sementes do chefe (so erupcoes de raizes).

## SYLVARA: 6 fases + S01 + Vyrkan implementados (graybox, com bots). Playtest humano, calibracao e arte final pendentes.

## CRISTALIA (fases 07-12 + S02) — mecanica: prismas, feixes e reflexos (graybox, todas com bot)
| Fase | Implementacao (resumo) |
|---|---|
| 07 O Despertar dos Cristais | 2 prismas girateis; cada cristal aceso forma uma ponte de luz sobre o abismo; checkpoint depois do 1o ativador; segredo: item `cristalia_07_prism_symbol` (1o simbolo Prisma Cosmico) |
| 08 O Labirinto dos Reflexos | prisma do chao + prisma alto (Zuri escala) + emissor ligado por dispositivo aereo (Pipa planeia); a parede so abre com a luz certa; item `cristalia_08_music_crystal`; checkpoint antes dos refletores |
| 09 O Jardim das Orquideas | 3 sinais de luz (chao, pedestal de Zuri, plataforma de Pipa) abrem o portao de luz do portal para a S02 (alem do bau); memoria `memory_orchid_signals_09`; checkpoint junto ao portal |
| 10 O Trem de Luz | carrinhos de cristal (plataformas moveis), tempestade de fragmentos (perseguicao) com buraco, resgate de criatura de cristais, colecionavel no trilho (`cristalia_10_rail_collectible`) |
| 11 A Catedral Prismatica | parede de luz (prisma) -> torre (Zuri escala) -> 2 mecanismos SINCRONIZADOS (6 s) -> salao do arquivo (memoria `memory_astralis_expedition_11`, confirma a Astralis); checkpoint antes da sequencia final |
| 12 Zythra, a Orquidea de Cristal | chefe: 3 etapas (prisma ao nucleo; flor real x ilusoes; planeio de Pipa) + Golpe Triade com 3 herois; semente `seed_cristalia`, guardiao `zythra`, `relic_cristalia`, `astralis_memory_cristalia`; reacao de Caeldron (Cristalia): "Reconhece a Astralis; fissura forte" |
| S02 Camara das Frequencias Perdidas | sequencia de 4 cristais musicais (ordem fixa, dica que pisca); itens Lente do Primeiro Explorador e item Prisma Cosmico |
Nao implementado em Cristalia: restauracao visual do planeta, cutscene de libertacao, ilusoes visuais mais ricas do chefe (so a flor real x falsas), pétalas/projeteis do chefe alem das faixas de erupcao, texto/imagem do arquivo.

## MECATRON (fases 13-18 + S03) — mecanica: esteiras, prensas e polaridade (graybox, todas com bot)
Pecas novas: `ConveyorBelt` (corpo estatico com velocidade constante, sentido por alavanca), `PolarityPlatform` (elevador/trilho que vai ao outro polo
a velocidade fixa; progresso capturavel), `HydraulicPress` (ciclo fixo IDLE 2,0 / aviso 0,8 / DOWN 0,6 / sobe 0,6; so fere em DOWN), `Mechanism.toggle` (alavanca que alterna), `GearDecor`.
| Fase | Implementacao (resumo) |
|---|---|
| 13 O Porto das Engrenagens | esteira a favor, esteira contraria (correr contra), elevador por alavanca sobre a plataforma; checkpoint apos a esteira simples; item `mecatron_13_techgear_part` (1o componente TecnoGear) |
| 14 As Esteiras de Titanio | barreira marcada (Rocco), esteira, 3 prensas em fases diferentes (aviso amarelo), rota alternativa de Zuri (escalada) ate `mecatron_14_industrial_decor`; checkpoint antes da sala |
| 15 O Trem do Eclipse | MESMA geometria da fase 10 (vagoes moveis, resgate, onda de raizes, buraco) com tema industrial; DESVIO: o acessorio NAO esta num vagao elevado (fica ao lado do resgate) |
| 16 O Labirinto Magnetico | 3 plataformas de polaridade (sobe, trilho sobre o vao, desce) + esteira rapida contraria (6 m/s > Rocco) que so cede com a alavanca do chao; beco com a pista `memory_workshop_clue_16` (a Oficina Zero nao tem portal aqui) |
| 17 A Forja Autonoma | esteira + 2 prensas + 2 elevadores + esteira invertida; painel escondido no alto (Zuri) abre o portal `mecatron_17_portal` para a S03; arquivo `memory_failed_expedition_17`; item `mecatron_17_forge_core` |
| 18 Ferrorraiz, o Cacto Mecanico | chefe: 1) dois interruptores ligados ao mesmo tempo (cada um dura 8 s), 2) ancora magnetica = elevador de polaridade que sobe com o heroi, 3) protecao no patamar alto; depois Golpe Triade com 3 herois; semente `seed_mecatron`, guardiao `ferrorraiz`, `relic_mecatron`, `astralis_memory_mecatron` |
| S03 Oficina Zero | elevador + trilho de polaridade em espaco compacto; `mecatron_s03_tech_accessory` e `memory_astralis_maintenance_s03` |
Nao implementado em Mecatron: arte final (tudo graybox), restauracao visual do planeta, cutscene de libertacao, bracos/espinhos/campo magnetico do chefe alem das faixas de erupcao,
magnetismo como forca (so polaridade de plataformas), segredo do acessorio no vagao elevado (fase 15), calibracao por playtest humano.


## AQUARYS

### Fases 23-24 (graybox, com bots)
Pecas novas: `TideFlux` (fluxo luminoso: acende quando todos os `WaterBody` exigidos estao nos niveis certos; opcionalmente e uma porta; estado derivado, nada a capturar), `SluiceControl.enabled` (comporta liberada por fase do chefe). Sem fisica de fluidos: cada reservatorio e um inteiro discreto (0..2).
| Fase | Implementacao (resumo) |
|---|---|
| 23 O Templo das Mares | comporta Oeste alta leva ao templo (checkpoint na entrada, antes do puzzle); no templo, dois reservatorios independentes (Oeste e Leste) com comportas para cada nivel; combinacao correta Oeste=1 + Leste=2 acende o fluxo e abre a porta; combinacoes erradas (2+2, 1+1) nao abrem; depois da porta: memoria antiga `memory_ancient_roots_23` (explica as raizes ligadas as sementes), bau especial `aquarys_23_chest` e o arco luminoso da entrada para Thalassa (a conclusao do bau leva a fase 24) |
| 24 Thalassa, a Vitoria-Regia | chefe: 1) comportas Oeste=2 + Leste=1 estabilizam o fluxo (ha uma comporta-isca do Leste que leva ao nivel errado), 2) a onda (reservatorio com degraus de 2 m) ergue a folha flutuante com o heroi ate o patamar, 3) desativar a protecao no alto; depois Golpe Triade com 3 herois; semente `seed_aquarys`, guardiao `thalassa`, `relic_aquarys`, `astralis_memory_aquarys`; Caeldron sente MEDO apos a quarta perda; os reservatorios reiniciam no checkpoint (snapshotable) |
Aquarys passa a ser jogavel no mapa (`playable = true`); Aerion (indice 4) passa a ser o planeta ainda em producao.
Nao implementado em Aquarys 23-24: arte final (tudo graybox), agua com fisica/visual de fluido, cutscene de libertacao, ataques do chefe alem das faixas de erupcao, portal real para Thalassa (a "entrada" e um arco decorativo; a ligacao e a ordem de fases), calibracao por playtest humano. As fases 21, 22 e a secreta S04 sao de outro trabalho.


## AQUARYS (fases 19-24 + S04) — mecanica: mares e comportas (graybox, todas com bot)
### Fases 21-22 + S04
| Fase | Implementacao (resumo) |
|---|---|
| 21 Os Recifes Esquecidos | duas correntes (`ConveyorBelt`: uma a favor, outra contra, 3 m/s < Rocco); checkpoint `aquarys_21_cp1` ao alcancar o recife; 6 plataformas transparentes (`RupturePlatform`) em 2 grupos, estabilizadas por 2 `Mechanism` (`link_id` reef_a / reef_b); inscricao no alto (Zuri escala) abre o portal `aquarys_21_portal` para a S04; arquivo `memory_first_explorer_21` |
| 22 A Onda Colossal | fuga: `ChaseWave` (7 m/s, comeca atras da largada em x=-8, gatilho x=44, depois do checkpoint x=34); Rocco quebra a barreira marcada, Zuri sobe o muro, Pipa planeia com vento ate a passarela alta; resgate opcional `aquarys_22_survivor`; laje elevada com moedas |
| S04 Oceano Esquecido | secreta (fora de `MAIN_ORDER`): comporta + 3 plataformas flutuantes + degraus de metal; 9 moedas, `aquarys_s04_expedition_badge` e `memory_old_expedition_recording_s04` |
Nao implementado: arte final (tudo graybox); a "plataforma transparente" da fase 21 reusa `RupturePlatform` (nao ha API de estabilizacao no `TideWalkway`); a onda da fase 22 e uma unica `ChaseWave` (nao ha agua visual invadindo o cenario); calibracao por playtest humano.

## AERION (fases 25-28; 29, 30 e o chefe Zefrion pendentes) — mecanica: vento e gravidade localizada (graybox, todas com bot)
Pecas novas: `WindVent` (corrente de vento na camada WIND; permanente ou dependente de um painel `control` ativo e de uma barreira `blocker` rompida; estado derivado), `ControlledPlatform` (ilha oculta: so existe com o painel ligado), vento HORIZONTAL no ar (`ActorController` soma `wind_push.x` a quem esta no ar; com `wind_push.x` > taxa de controle aereo o vento realmente carrega; ver fase 25) e gravidade invertida (escala de gravidade NEGATIVA em zona WIND: o heroi sobe ate o teto e segue encostado nele; velocidade de subida limitada; comportamento com escala >= 0 inalterado).
| Fase | Implementacao (resumo) |
|---|---|
| 25 O Porto das Nuvens | vao de 7 m com vento de popa (40 m/s2 horizontal; sem o vento o salto cai), checkpoint apos a primeira corrente, degraus suspensos ate o observatorio (decoracao), bau; item `aerion_25_horizon_item` (Horizonte) sobre o ultimo degrau (fica NA rota) |
| 26 Os Jardins Suspensos | Pipa planeia 2 lacunas de 9 m com corrente ascendente (mesma geometria da fase 08), Rocco rompe a barreira, Zuri escala a estrutura que flutua; checkpoint antes das lacunas; item `aerion_26_cloud_seed` sob a estrutura (fora da rota); a "rota opcional nas nuvens" NAO foi feita alem desse item |
| 27 Corredores do Vento | travessia 1 com corrente permanente (Pipa); Zuri liga o painel no alto; Rocco rompe a barreira que cobre a base da 2a corrente; so painel + base livre fazem a corrente soprar (Pipa planeia); o painel revela a ilha oculta com a memoria `memory_secret_portal_clue_27` (pista do portal da S05). DESVIO: a "corrente invertida" e simplificada: a ilha aparece quando o painel liga (o painel ja e obrigatorio) |
| 28 O Ceu de Cabeca para Baixo | 3 zonas de gravidade invertida (poco, pilar de 3,5 m que so passa pelo teto, poco longo) com teto solido; simbolos no chao na entrada; templos espelhados (decoracao) em plano duplo; checkpoint antes da inversao do pilar; item `aerion_28_gravity_clue` sobre o pilar. DESVIO: nao ha andar no teto como piso (pular/virar o personagem); o heroi e levado ate o teto e desliza por ele ate sair da zona, sem inverter controles nem camera |
Nao implementado em Aerion: fases 29-30, chefe Zefrion, S05, semente `seed_aerion` (Aerion segue com `playable = false`), arte final, calibracao por playtest humano, vento visivel (particulas), rota opcional nas nuvens da fase 26.

## UMBRAXIS (fases 31-36 + S06) — mecanica: combinacao e ruptura dimensional (graybox, todas com bot; planeta ainda NAO jogavel)
Pecas novas: `EchoStone` (pedra-eco: uma real e ilusoes distinguiveis por EVIDENCIA — pisca ou forma —; tocar a real estabiliza plataformas de ruptura do mesmo `link_id`; tocar ilusao tira um coracao), `UmbraxisModules` (modulos reutilizaveis de Sylvara/Cristalia/Mecatron/Aquarys/Aerion), `NecryonBoss`.
| Fase | Implementacao (resumo) |
|---|---|
| 31 O Limiar das Raizes | 3 plataformas dimensionais instaveis (aviso) ate a ilha; checkpoint DEPOIS do pouso e do primeiro risco; `umbraxis_31_legacy_fragment` (1o fragmento do Legado Celestial) na plataforma alta (Zuri); raizes e olho de Caeldron so como decoracao |
| 32 As Fases Quebradas | 5 modulos em fila (barreira de Rocco, plataforma movel, esteira + elevadores, mare, muro + planeio) com 4 checkpoints entre eles; `memory_hidden_record_32`; o "atalho dimensional" NAO foi implementado |
| 33 O Jardim dos Ecos | 2 conjuntos de pedras-eco (1: ilusoes piscam; 2: ilusoes finas) que estabilizam a travessia; projecoes da tripulacao (decoracao); inscricao no alto (Zuri) abre o portal `umbraxis_33_portal` para a S06; `umbraxis_33_crew_suit`, `memory_expedition_projection_33`; checkpoints antes das ilusoes e perto do portal |
| 34 A Estrada para o Coracao | prensa-raiz sinalizada, barreira de Caeldron (Rocco), checkpoint antes do trecho dificil, 2 escaladas (Zuri), plataformas temporarias, resgate opcional `umbraxis_34_survivor`; o espelho de cosmeticos e so decoracao |
| 35 A Ultima Mensagem | sintese das 5 mecanicas em ordem; terminal destranca o bau; `memory_last_message_35`; checkpoint depois da mensagem; "reduzir movimento" troca a plataforma movel por ponte fixa |
| 36 Necryon e a Ultima Semente | chefe `NecryonBoss`: 1) combinacao (fechadura de 4 cristais), 2) pedra-eco real por evidencia (erro = -1 coracao + reinicia o ciclo), 3) ruptura (estabilizador, travessia, escalada, selar o nucleo); Golpe Triade (3 herois); `seed_umbraxis`, guardiao `necryon`, `relic_umbraxis`, `astralis_memory_umbraxis`; so a mensagem de reacao de Caeldron (SEM final/cutscene) |
| S06 Camara da Primeira Expedicao | secreta: 1 conjunto de pedras-eco leves + fechadura de sequencia final; `umbraxis_s06_expedition_suit` e `memory_first_expedition_final_s06` |
Nao implementado: arte final, Umbraxis jogavel no mapa, final/cutscene/Caeldron, atalho dimensional (32), seletor de cosmeticos (34), calibracao por playtest humano. Os modulos da fase 32/35 ficam todos na mesma cena (nao ha descarregamento real de mundos).
