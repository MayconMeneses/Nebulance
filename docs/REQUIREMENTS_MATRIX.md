# REQUIREMENTS_MATRIX — inventário e rastreabilidade

Fonte: `NEBULANCE_Prompt_Mestre_Supremo_Engenharia_Completa (1).pdf` (48 páginas; texto lido integralmente via `pdftotext`; 6 imagens extraídas e vistas). Status em 2026-10-31.
Classes de decisão do PDF: **A** = aprovado, **B** = valor a balancear, **F** = evolução futura (não implementar), **X** = proibido.
Status: CT = concluído e testado · IMP = implementado, aguardando validação · DEV = em desenvolvimento · PEND = pendente · BLQ = bloqueado.

## Requisitos de produto (PDF §19)
| ID | Requisito | Cl. | Evidência exigida | Status |
|---|---|---|---|---|
| RF-001 | 6 planetas / 36 principais + 6 secretas = 42 fases, portais, chefes | A | Level bible, TC-026 | PEND |
| RF-002 | 3 heróis (Rocco, Zuri, Pipa), movimento e troca segura | A | TC-003..008 | PEND (só corpo provisório com salto) |
| RF-003 | 5 vidas, 3 corações (Aventura), 3 dificuldades | A/B | TC-009..012 | PEND |
| RF-004 | Combate sem armas; guardiões libertados; Caeldron morre | A | TC-029..035 | PEND |
| RF-005 | Mapa Galáctico Vivo e viagens da Astralis | A | TC-025..028 | PEND |
| RF-006 | Portais e salas secretas (S01–S06) | A | TC-014 | PEND |
| RF-007 | Baús, moedas, loja, cosméticos, recompensas únicas | A/B | TC-015..019 | PEND |
| RF-008 | Planetas restaurados e pós-campanha | A | TC-027,028,036 | PEND |
| RNF-001 | Build Windows offline, sem IA/MCP/rede | A | TC-001,037,038 | PEND |
| RNF-002 | Desempenho medido, perfis Baixo/Médio/Alto | B | TC-039 | PEND |
| RNF-003 | Acessibilidade, cinemáticas puláveis | A | TC-023..025 | PEND |
| RNF-004 | Código modular, sem God File, arte editável | A | revisão, ADR | DEV (estrutura criada; verificação por contagem de linhas abaixo) |
| SEC-001 | Ferramentas de terceiros auditadas | A | TOOLS_AND_MCPS | DEV (Godot auditado por hash; nenhuma outra instalada) |
| SEC-002 | Save local versionado, tolerante a corrupção | A | TC-016..021 | PEND |
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
| Preparar ambiente (Godot) | CT; Blender/Krita/Audacity/templates PEND |
| Estrutura inicial | CT |
| Git inicializado | ver relatório |
| Projeto Godot mínimo abre e roda | CT (headless + janela) |
| Riscos e decisões registrados | CT (ADR 0001–0003, relatório) |

## TC-001..TC-040 (PDF §18) — estado atual
Executados: nenhum dos TC oficiais. Os testes da Fase Zero (`tests/run_tests.gd`) são de fundação e NÃO substituem a matriz TC.
TC-003..009 (núcleo) → Fase 2 · TC-001,002,010–025 → Fase 3 · TC-026..036 → Fases 4–6 · TC-037..040 → Fase 7.

## Catálogo de conteúdo (do PDF)
- Planetas/guardiões: Sylvara/Vyrkan · Cristália/Zythra · Mecatron/Ferrorraiz · Aquarys/Thalassa · Aerion/Zefrion · Umbraxis/Necryon. Vilão: Caeldron.
- Fases 01–36 e S01 Jardim Além do Portal, S02 Câmara das Frequências Perdidas, S03 Oficina Zero, S04 Oceano Esquecido, S05 Jardim Sem Gravidade, S06 Câmara da Primeira Expedição (detalhes no PDF §10; LEVEL_BIBLE ainda por escrever).
- Cinemáticas (referência): abertura 45–75 s, chegada de planeta 15–25 s, descoberta 3–8 s, baú 3–6 s, vitória de boss 20–35 s, final 60–100 s.
