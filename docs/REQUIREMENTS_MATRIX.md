# REQUIREMENTS_MATRIX — inventário e rastreabilidade

Fonte: `NEBULANCE_Prompt_Mestre_Supremo_Engenharia_Completa (1).pdf` (48 páginas; texto lido integralmente via `pdftotext`; 6 imagens extraídas e vistas). Status em 2026-10-31.
Classes de decisão do PDF: **A** = aprovado, **B** = valor a balancear, **F** = evolução futura (não implementar), **X** = proibido.
Status: CT = concluído e testado · IMP = implementado, aguardando validação · DEV = em desenvolvimento · PEND = pendente · BLQ = bloqueado.

## Requisitos de produto (PDF §19)
| ID | Requisito | Cl. | Evidência exigida | Status |
|---|---|---|---|---|
| RF-001 | 6 planetas / 36 principais + 6 secretas = 42 fases, portais, chefes | A | Level bible, TC-026 | DEV: 1 de 42 fases (sylvara_01, graybox, o bot completa); portais e chefes PEND |
| RF-002 | 3 heróis (Rocco, Zuri, Pipa), movimento e troca segura | A | TC-003..008 | IMP, testado automaticamente (TC-003..008 PASS); aguarda playtest humano; habilidades secundárias PEND (ADR-0005) |
| RF-003 | 5 vidas, 3 corações (Aventura), 3 dificuldades | A/B | TC-009..012 | IMP, TC-009..011 PASS, TC-012 parcial; seleção de dificuldade e persistência PEND |
| RF-004 | Combate sem armas; guardiões libertados; Caeldron morre | A | TC-029..035 | PEND |
| RF-005 | Mapa Galáctico Vivo e viagens da Astralis | A | TC-025..028 | PEND |
| RF-006 | Portais e salas secretas (S01–S06) | A | TC-014 | PEND |
| RF-007 | Baús, moedas, loja, cosméticos, recompensas únicas | A/B | TC-015..019 | IMP: baú, moedas, itens únicos, ledger (TC-015..017 PASS); loja e cosméticos PEND |
| RF-008 | Planetas restaurados e pós-campanha | A | TC-027,028,036 | PEND |
| RNF-001 | Build Windows offline, sem IA/MCP/rede | A | TC-001,037,038 | DEV (build roda sem conexões observadas; faltam testes com rede bloqueada e máquina limpa) |
| RNF-002 | Desempenho medido, perfis Baixo/Médio/Alto | B | TC-039 | PEND |
| RNF-003 | Acessibilidade, cinemáticas puláveis | A | TC-023..025 | PARCIAL (TC-023 remapeamento de teclado PASS; legendas e reduzir movimento pendentes) |
| RNF-004 | Código modular, sem God File, arte editável | A | revisão, ADR | DEV (maior arquivo de jogo: 197 linhas; 38 scripts em game/) |
| SEC-001 | Ferramentas de terceiros auditadas | A | TOOLS_AND_MCPS | DEV (Godot, Blender, Krita, Audacity e templates com hash oficial conferido; sem MCPs) |
| SEC-002 | Save local versionado, tolerante a corrupção | A | TC-016..021 | IMP: TC-016,017,020,021 PASS; disco cheio/permissão NOT_RUN |
| LEGAL-001 | Licenças e marca verificadas antes da venda | A | ASSET_LICENSES | PEND (marca NÃO pesquisada) |

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
| Git inicializado | CT (remoto GitHub configurado e enviado) |
| Projeto Godot mínimo abre e roda | CT (headless + janela) |
| Riscos e decisões registrados | CT (ADR 0001–0005, relatórios) |

## TC-001..TC-040 (PDF §18) — estado atual
Ver docs/QA_PLAN.md (estado atualizado por TC). Executados com PASS: TC-003 a TC-011. Parciais: 001, 012, 037, 038, 040.

## Catálogo de conteúdo (do PDF)
- Planetas/guardiões: Sylvara/Vyrkan · Cristália/Zythra · Mecatron/Ferrorraiz · Aquarys/Thalassa · Aerion/Zefrion · Umbraxis/Necryon. Vilão: Caeldron.
- Fases 01–36 e S01 Jardim Além do Portal, S02 Câmara das Frequências Perdidas, S03 Oficina Zero, S04 Oceano Esquecido, S05 Jardim Sem Gravidade, S06 Câmara da Primeira Expedição (detalhes no PDF §10; LEVEL_BIBLE ainda por escrever).
- Cinemáticas (referência): abertura 45–75 s, chegada de planeta 15–25 s, descoberta 3–8 s, baú 3–6 s, vitória de boss 20–35 s, final 60–100 s.

## Atualizacao Fases 4 e 5
- RF-001: 7 das 42 fases implementadas (Sylvara 01-06 e a secreta S01), todas com bot; portais: 1 (sylvara_03 -> S01). Chefes: 1 de 6 (Vyrkan).
- RF-005 (Mapa Galactico): mapa derivado do save, 6 planetas, raizes, painel sem spoilers, modo QA; viagens da Astralis reduzidas a chegada 3D pulavel (sem decolagem/tunel).
- RF-006 (portais): 1 portal funcional; faltam os demais secretos (S02-S06).
- RNF-002: perfis graficos e benchmark registrados; 60 FPS em hardware-alvo NAO validado.
- Visual: modelos 3D de primeira passagem (ADR-0007); fidelidade a arte aprovada NAO validada pelo dono.
- Gap do PDF §22 item 07 (portal menor no vertical slice): atendido pelo portal da fase 03 -> S01.

## Atualizacao Sylvara completa
- RF-004 (combate sem armas, guardiao libertado): Vyrkan implementado (graybox) e libertado no save; Caeldron e os outros 5 guardioes PEND.
- RF-008: Sylvara salvo no mapa (raiz removida, Cristalia disponivel); restauracao visual PEND.

## Atualizacao Cristalia
- RF-001: 14 das 42 fases (Sylvara 01-06 + S01; Cristalia 07-12 + S02), todas com bot. Portais: 2 (sylvara_03 -> S01, cristalia_09 -> S02). Chefes: 2 de 6 (Vyrkan, Zythra).
- RF-004/RF-008: 2 guardioes libertados e 2 sementes destruidas no save; restauracao visual PEND.
- Suite completa: 436 checagens.
