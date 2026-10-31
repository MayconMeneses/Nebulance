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
