# RELATORIO - FASE 3 / Vertical slice de Sylvara (fase 01)
Data: 2026-10-31
Ambiente: Windows, i5-8265U, Intel UHD 620, 8,43 GB RAM; Godot 4.7.2; gl_compatibility.
Escopo: RF-001 (1/42), RF-007, SEC-002, TC-013, 015–017, 020, 021 e parciais 001, 002, 025, 037, 038.

## Entregue (tudo executado nesta fase)
SaveService atômico + esquema SaveGameV1 + backup/quarentena; RewardLedger idempotente e critérios Bronze/Prata/Ouro (docs/ECONOMY.md); LevelSession (tentativa × perfil) com snapshot no checkpoint; Pickup, Chest, PatrolEnemy (telégrafo; só fere em PATROL/LUNGE), LevelController, SegmentBuilder; fase 01 completa (docs/LEVEL_BIBLE.md); HUD, MainMenu (foco por teclado), ResultsScreen, introdução pulável, pausa, GameFlow; 7 SFX e o tema de Sylvara gerados por script próprio (tools/make_audio.py); ADR-0006; bot e benchmark de jogo real.

## Testes: 197 checagens, 0 falhas, exit 0 (headless)
Ver docs/QA_PLAN.md. Destaques: um bot joga a fase inteira sem teleporte usando os 3 heróis (Ouro, 9/9 moedas, 0 vidas perdidas); um segundo processo reabre o save; 8 casos de save corrompido.
Mutações (código quebrado de propósito e restaurado): ledger sem checagem de ID → FAIL (TC-016); save sem backup → FAIL (TC-021); checkpoint sem restauração → FAIL; sem vento → o bot não alcança o segredo; sem salto duplo → o bot para no muro; sem investida → o bot para na barreira; pausa sem PAUSABLE → FAIL.

## Bugs encontrados e corrigidos
1. Pausa não pausava a fase (o fluxo em ALWAYS era herdado). Corrigido (fase PAUSABLE); teste de regressão + mutação.
2. Menu: o foco caía em itens desativados. Corrigido (FOCUS_NONE nos desativados); teste de regressão.
3. Runner: suíte isolada falhava (nós sem _ready no 1º quadro). Corrigido (espera 1 quadro).
4. Bench: o gancho --bench criava benchmark recursivo no fluxo interno. Corrigido (flag dev_hooks). O crash 0xC0000005 do build exportado ocorreu nessa versão recursiva e não se repetiu após a correção; a relação causa→efeito é PROVÁVEL, não isolada.
5. Furo de teste: a mutação da marcação de alvos passava; adicionado o caso "alvo sem marcação". Erros de expectativa dos próprios testes (distância, ciclo do inimigo) corrigidos pela física/contrato, sem afrouxar.

## Desempenho (dev; NÃO é o hardware-alvo)
Build exportado, bot jogando a fase 01 com HUD e áudio: 1086 quadros, média 59,0 FPS, 1% low 59,5, pior quadro 145,4 ms (travamento único). Sem export: média 58,2, 1% low 48,3. Vsync/monitor não verificados.

## Não verificado / pendente
Playtest humano ("clara e divertida"): NOT_RUN. Gamepad físico: NOT_RUN. Disco cheio / permissão negada: NOT_RUN. Rede bloqueada (TC-001): só observação de conexões. Instalação em máquina limpa: NOT_RUN. Visual, áudio, introdução e HUD são provisórios; sem modelos 3D finais. Portais, loja, cosméticos, dificuldade selecionável, remapeamento e acessibilidade: pendentes. `tests/` ainda vai no pacote exportado.
Gate da Fase 3 (PDF): TC-001, 002, 010–025 "parcialmente executados" → ATENDIDO PARCIALMENTE; "1 fase divertida" depende do playtest do dono → NÃO aprovado.
