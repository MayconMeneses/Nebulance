# RELATORIO - FASE 2 / Núcleo de controles (gate: TC-003 a TC-009)
Data: 2026-10-31
Ambiente: Windows, i5-8265U, Intel UHD 620, 8,43 GB RAM; Godot 4.7.2; gl_compatibility.
Escopo executado: RF-002, RF-003 (parcial), TC-003..TC-012, TC-005.

## Entregue
- `ActorController` único (CharacterBody3D) com estados do PDF, coyote time, jump buffer, salto variável, aceleração/desaceleração, controle no ar, knockback e invulnerabilidade (`TrioVitals`).
- 3 heróis como `HeroProfile` (.tres): Rocco (investida em alvos marcados), Zuri (salto duplo e escalada em superfícies marcadas), Pipa (planeio limitado e vento).
- `HeroSwapper` com validação por forma (pés alinhados), `TrioRig`, checkpoint, abismo, `SideCamera`, visuais provisórios, playground jogável.
- ADR-0005, CONTROLS.md, QA_PLAN.md. Detalhes de design em docs/ADR/0005.

## Testes (headless, `tests/run_tests.gd`): 102 checagens, 0 falhas, exit 0
TC-003, 004, 005, 006, 007, 008, 009, 010, 011: PASS. TC-012: PARCIAL (sem save). Câmera e smoke do playground: PASS.
Mutação (código quebrado de propósito, restaurado depois): sem validação de espaço (TC-004) → 3 FAIL; sem invulnerabilidade (TC-009) → 3 FAIL; sem coyote (TC-005) → 1 FAIL; ignorar marcação de alvo (TC-006) → inicialmente NÃO detectado (furo no teste), corrigido com caso "alvo não marcado" e redetectado (1 FAIL).
Bug do teste (não do jogo): expectativa de distância em 0,5 s estava errada (3 m vs 2,4 m calculado); corrigida pela física, não afrouxada.
Fase Zero: os testes de fundação continuam (suite_foundation); o corpo provisório `TestPlatformBody` segue na cena de teste antiga. Nenhum teste foi apagado.

## Desempenho (máquina de desenvolvimento, NÃO é o alvo)
Build exportado, `-- --bench`, 15 s, graybox: 901 quadros, média 60,0 FPS, 1% low 60,0 FPS, pior quadro 16,7 ms (provável limite de vsync). Não prova 60 FPS em jogo real.

## Não verificado / pendente
Playtest humano (conforto da câmera, sensação do salto, troca no ar), gamepad físico, hitboxes por animação, habilidades secundárias (empurrar, latido, rajada, bicada, esquiva), seleção de dificuldade, persistência (TC-012), HUD final.
Gate Fase 2 (PDF): TC-003..009 PASS automatizado; "playtest de resposta" NOT_RUN → gate APROVADO PARCIAL, depende do playtest do dono.

## Commits
Autoria Maycon; ver `git log`.
