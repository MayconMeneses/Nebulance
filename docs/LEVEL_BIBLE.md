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

## PENDENTES de Sylvara (Fase 5): fases 04, 05 e 06 (Vyrkan), destruicao da primeira semente, rota para Cristalia, primeira reliquia.
