# REQUIREMENTS_MATRIX — inventário e rastreabilidade

Fonte: `NEBULANCE_Prompt_Mestre_Supremo_Engenharia_Completa (1).pdf` (48 páginas; texto lido integralmente via `pdftotext`; 6 imagens extraídas e vistas). Estado revisado em 2026-11-03 sobre `main` `89e5d90` (42 fases em graybox). Revisão só de documentação.
Classes de decisão do PDF: **A** = aprovado, **B** = valor a balancear, **F** = evolução futura (não implementar), **X** = proibido.
Status: **PASS** = coberto por teste automatizado que passou · **IMP** = implementado, com PASS automatizado no que é testável, sem validação humana · **PARCIAL** · **PEND** = não implementado · **NOT_RUN** = exige humano/hardware, não executado. BLOCKED/NOT_RUN não são aprovação.
Procedência dos números: ver o topo de `docs/QA_PLAN.md` (792 checagens informadas nos commits de merge; não reexecutadas nesta revisão).

## Requisitos de produto (PDF §19)
| ID | Requisito | Cl. | Evidência exigida | Status real |
|---|---|---|---|---|
| RF-001 | 6 planetas / 36 principais + 6 secretas = 42 fases, portais, chefes | A | Level bible, TC-026 | **IMP**: 42 de 42 fases existem em graybox (Sylvara 01-06, Cristália 07-12, Mecatron 13-18, Aquarys 19-24, Aerion 25-30, Umbraxis 31-36 + S01..S06), cada uma com bot que a completa sem teleporte (`docs/REPORTS/phase-07-campanha.md`); 6 portais e 6 chefes testados. Arte final, calibração e playtest humano: NOT_RUN. Umbraxis ainda `playable = false` no mapa |
| RF-002 | 3 heróis (Rocco, Zuri, Pipa), movimento e troca segura | A | TC-003..008 | **IMP**, TC-003..008 PASS; playtest humano NOT_RUN; habilidades secundárias PEND (ADR-0005) |
| RF-003 | 5 vidas, 3 corações (Aventura), 3 dificuldades | A/B | TC-009..012 | **IMP**: TC-009..011 PASS, TC-012 PARCIAL; seleção de dificuldade na interface e troca sem perder campanha (TC-022) PEND |
| RF-004 | Combate sem armas; guardiões libertados; Caeldron morre | A | TC-029..035 | **PARCIAL**: 6 de 6 guardiões libertados no save com chefe testado (Vyrkan, Zythra, Ferrorraiz, Thalassa, Zefrion, Necryon; TC-029..034). **Caeldron morrer / final (TC-035): PEND em `main` 89e5d90** |
| RF-005 | Mapa Galáctico Vivo e viagens da Astralis | A | TC-025..028 | **PARCIAL**: mapa derivado do save com 6 planetas e raízes; 5 de 6 planetas jogáveis (Umbraxis não); viagens da Astralis reduzidas à chegada 3D pulável (sem decolagem/túnel); TC-026 PARCIAL |
| RF-006 | Portais e salas secretas (S01–S06) | A | TC-014 | **IMP**: 6 portais (sylvara_03, cristalia_09, mecatron_17, aquarys_21, aerion_28, umbraxis_33) e 6 secretas com bot; ida e volta pelo fluxo completo exercitada em S01 e S05 (nas outras, abertura do portal e catálogo) |
| RF-007 | Baús, moedas, loja, cosméticos, recompensas únicas | A/B | TC-015..019 | **IMP**: baú, moedas, itens únicos, ledger (TC-015..017 PASS). Loja (TC-018) e cosméticos equipáveis (TC-019): PEND |
| RF-008 | Planetas restaurados e pós-campanha | A | TC-027,028,036 | **PARCIAL**: estado no save/mapa PASS (TC-027, 028 parcial). Restauração visual e pós-final (TC-036): PEND |
| RNF-001 | Build Windows offline, sem IA/MCP/rede | A | TC-001,037,038 | **PARCIAL/risco**: sem IA/MCP. **Desde a v0.4.0 há uma consulta de atualização (GET a `api.github.com`, ligada por padrão, desligável)**: é o único uso de rede, mas contraria o requisito "sem rede" lido ao pé da letra — decisão do dono pendente. Build da versão atual não exportado/validado em máquina limpa nem com rede bloqueada (NOT_RUN) |
| RNF-002 | Desempenho medido, perfis Baixo/Médio/Alto | B | TC-039 | **PARCIAL**: perfis existem e funcionam; medições só da fase 01 em Intel UHD 620 (não é o alvo; 60 FPS estáveis NÃO atingidos em Médio/Alto com vsync). FPS em hardware-alvo e das fases novas: NOT_RUN |
| RNF-003 | Acessibilidade, cinemáticas puláveis | A | TC-023..025 | **PARCIAL**: remapeamento de teclado PASS (TC-023); reduzir movimento/flashes PASS; legendas e contraste NOT_RUN (sem diálogo falado); gamepad físico NOT_RUN; controles de toque testados só em PC (`suite_touch`), aparelho real/Android NOT_RUN |
| RNF-004 | Código modular, sem God File, arte editável | A | revisão, ADR | **PARCIAL**: 137 scripts em `game/`. Maior arquivo: `game/core/game_flow.gd` com **319 linhas** (acima do limite de 200 que o projeto adotou); `actor_controller.gd` tem 198. Nos testes: `tests/support/level_bot_umbraxis.gd` 265 e `suite_boss.gd` 208. Não há teste automatizado que verifique o limite |
| SEC-001 | Ferramentas de terceiros auditadas | A | TOOLS_AND_MCPS | DEV (Godot, Blender, Krita, Audacity e templates com hash oficial conferido; sem MCPs) |
| SEC-002 | Save local versionado, tolerante a corrupção | A | TC-016..021 | **IMP**: TC-016,017,020,021 PASS; disco cheio/permissão NOT_RUN |
| LEGAL-001 | Licenças e marca verificadas antes da venda | A | ASSET_LICENSES | PEND (marca NÃO pesquisada; modelos 3D e áudio são de primeira passagem) |

## Evolução futura / proibido (não implementar)
F: modo foto, galeria avançada, criação de fases pelo usuário, co-op local, expansões.
X: IA generativa em runtime, API, login, cloud, DRM online, multiplayer online, armas, pay-to-win, loot box, duplicação de recompensas.

## Critérios da Fase Zero e estado
| Item | Status |
|---|---|
| Ler PDF integralmente | CT (texto 48 págs + 6 imagens) |
| Inventário de requisitos | CT (este arquivo) |
| Verificar ferramentas | CT (ver ENVIRONMENT.md) |
| Pesquisa com ≥10 fontes distintas | PEND — só 1 fonte externa consultada (API GitHub do Godot) + as 30 referências do PDF NÃO revalidadas |
| Preparar ambiente | CT (Godot, Blender, Krita, Audacity, templates, build mínimo) |
| Estrutura inicial | CT |
| Git inicializado | CT (remoto GitHub configurado) |
| Projeto Godot mínimo abre e roda | CT (headless + janela) |
| Riscos e decisões registrados | CT (ADR 0001–0009, relatórios) |

## TC-001..TC-040 (PDF §18) — estado atual
Ver `docs/QA_PLAN.md` (um estado e uma evidência por TC). Resumo: PASS 21, PARCIAL 14, NOT_RUN 5, FAIL 0, BLOCKED 0.

## Catálogo de conteúdo (do PDF) e estado
- Planetas/guardiões: Sylvara/Vyrkan · Cristália/Zythra · Mecatron/Ferrorraiz · Aquarys/Thalassa · Aerion/Zefrion · Umbraxis/Necryon. Vilão: Caeldron (aparece só como reação por semente e decoração; **sem confronto final**).
- Fases 01–36 e S01–S06: todas em graybox (tabela em `docs/REPORTS/phase-07-campanha.md`; detalhes em `docs/LEVEL_BIBLE.md`).
- Cinemáticas (referência do PDF): abertura 45–75 s, chegada de planeta 15–25 s, descoberta 3–8 s, baú 3–6 s, vitória de boss 20–35 s, final 60–100 s. Estado: só a introdução da Astralis (pulável) e a reação de Caeldron; sem cutscene de libertação, de vitória de chefe ou final.

## Histórico (resumo das atualizações anteriores)
- Fases 4 e 5: Sylvara completa (6 fases + S01 + Vyrkan), mapa derivado do save, perfis gráficos, visual 3D de primeira passagem (ADR-0007).
- Cristália (fases 07–12 + S02, Zythra): sistema de feixes e prismas (ADR-0009); suite de 436 checagens na época.
- Mecatron (13–18 + S03), Aquarys (19–24 + S04), Aerion (25–30 + S05) e Umbraxis (31–36 + S06): ver LEVEL_BIBLE; regressões informadas de 686, 750 e 792 checagens nos merges mais recentes.
