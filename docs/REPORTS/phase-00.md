# RELATORIO - FASE 0 / Auditoria e preparação
Data/hora: 2026-10-31
Ambiente: Windows (build 10.0.26300; `Get-ComputerInfo` diz "Windows 10 Home"), i5-8265U, Intel UHD 620 (27.20.100.8681), 8,43 GB RAM, 50,9 GB livres em C:. Godot 4.7.2-stable; Git 2.55.0; Git LFS 3.7.1.
Escopo aprovado executado: RNF-004 (estrutura), SEC-001 (parcial), critérios de Fase Zero (ver REQUIREMENTS_MATRIX.md).

## Arquivos criados
Ver árvore em `README.md`/`git ls-files`. Código: `game/actors/shared/test_platform_body.gd` (21 linhas), `tests/run_tests.gd` (56), `tests/scenes/test_platform_scene.tscn` (32). Config: `project.godot`, `.gitignore`, `.gitattributes`. Docs: ENVIRONMENT, TOOLS_AND_MCPS, REQUIREMENTS_MATRIX, ADR 0001–0003. 37 diretórios do PDF §12 criados com `.gitkeep`.

## Testes (todos headless, comando literal em ENVIRONMENT.md)
| Teste | Resultado |
|---|---|
| 8 ações do InputMap existem, ≥2 eventos cada (teclado+gamepad) | PASS |
| move_left tem teclado A, seta e analógico (3 eventos) | PASS |
| Cena de teste carrega; Body é CharacterBody3D | PASS |
| Corpo cai e pousa no piso (y=0.800) | PASS |
| Salto sobe 1,73 u e volta ao piso | PASS |
| Plano lateral (z travado) preservado | PASS |
| Mutação (jump_velocity=0) → teste de salto falha (exit 1); restaurado → PASS (exit 0) | PASS (prova que o teste detecta regressão) |
| Cena principal abre em janela por 180 frames e fecha, exit 0, OpenGL Compatibility na UHD 620 | PASS (sem inspeção visual: não vi a janela) |
| Hash SHA-512 do zip do Godot = hash publicado | PASS |
| Git: `.godot/` e `*.pdf` ignorados; `.uid` versionados | PASS |
| Linhas por arquivo (anti-God File): máx. 56 | PASS |
| Pesquisa técnica com ≥10 fontes | NOT_RUN (só API do GitHub do Godot consultada) |
| Revalidar as 30 referências [R01–R30] do PDF | NOT_RUN |
| Verificação de assinatura GPG do Godot | NOT_RUN |
| Pipeline Blender→Godot, Krita→PNG, Audacity→áudio | NOT_RUN (ferramentas ausentes) |
| Export templates / build Windows fora do editor | NOT_RUN |
| Playtest humano / FPS | NOT_RUN |

Nenhum dos TC-001..040 oficiais foi executado.

## Bugs
Nenhum bug de produto. Obstáculos de ambiente: o leitor de PDF (`pdftoppm`) não existe; contornado com `pdftotext` (texto) e script próprio para extrair as 6 imagens. Imagens do PDF NÃO foram copiadas para o repositório (ficam em `docs/reference/`, ignorado).

## Inconsistências e riscos do PDF (para decisão)
1. **Texto × arte dos guardiões** (o próprio Anexo C avisa de divergência). Arte: Ferrorraiz "Planta Mecânica" com tentáculos; Thalassa "Alga Abissal"; Zefrion "Cipreste Celestial"; Necryon "Planta das Sombras". Texto: cacto, vitória-régia, dente-de-leão, flor-cadáver. Proposta: texto vence (PDF diz que o texto é a especificação e a arte é só silhueta/atmosfera); confirmar.
2. **Arte × "sem armas"**: o painel dos guardiões cita "mísseis de sementes/projéteis teleguiados", "serras", "explosões". Implementar só como telegraphs ambientais, nunca armas.
3. **Controles**: Q/E para trocar e E para interagir (ADR-0003).
4. **Fase 16 × S03**: texto diz "Portal menor ou acesso à Oficina Zero" (16) e "acesso confirmado na 17" — definir qual é o portal oficial.
5. **Ambiguidade**: o PDF pede na VISUAL_BIBLE "11 elementos", mas a tabela da seção 11 lista 6 linhas (Rocco, Zuri, Pipa, Astralis, Caeldron, Chefões). Provável referência à seção 11; a confirmar.
6. **Caminho com "OneDrive"**: a OneDrive está desativada (sem processo nem conta; ADR-0004). Risco de sincronização descartado enquanto continuar assim. Backup externo recomendado.
7. **Hardware**: 8 GB/UHD 620 é muito modesto; meta de 60 FPS só se mede aqui e não prova hardware-alvo.
8. **Marca**: disponibilidade de "NEBULANCE" não pesquisada.

## Backups/commits
Repositório inicializado, branch `main`. Commit `22685d4` (autoria: Maycon). Sem remoto; nada publicado.

## Gate
Fase Zero: APROVADO para o escopo "auditoria + projeto Godot mínimo + estrutura". Gate de "Ambiente" do PDF (tabela §18, fase 1): PENDENTE (Blender, Krita, Audacity, templates, build mínimo).

## Proximo passo
Decidir local do repositório (item 6) e confirmar itens 1–4; depois instalar Blender/Krita/Audacity (fontes oficiais, hash), provar Blender→Godot, exportar build mínimo Windows e então iniciar Fase 1/2 (controller, troca, câmera).
