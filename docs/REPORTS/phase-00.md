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

## Adendo — ambiente completo (2026-10-31)
Instalados (portáteis, hash oficial conferido): Blender 5.2.3 LTS, Krita 6.0.4.1, Audacity 4.0.1, export templates Godot 4.7.2.

| Teste | Resultado |
|---|---|
| Hashes: templates (SHA-512), Blender, Audacity, Krita (SHA-256) = publicados | PASS |
| Blender: cubo com material → `.blend` + `.glb` (`tools/blender_make_test_asset.py`) | PASS |
| Godot importa `.glb` (1 mesh, AABB 1×1×1) | PASS |
| Krita CLI: PNG → `.kra` → PNG; Godot lê alpha (canto transparente, centro opaco) | PASS |
| Godot: bus SFX existe; WAV importa e toca no bus SFX | PASS |
| Formato das 6 skills locais | PASS |
| Suíte completa headless: 33 checagens, 0 falhas, exit 0 | PASS |
| Export Windows release (`build/nebulance_phase0.exe`, 109 MB) | PASS |
| `.exe` fora do editor: `--quit-after 240` termina com exit 0; OpenGL Compatibility na UHD 620 | PASS |
| `.exe` em execução por 10 s: 0 conexões TCP e 0 endpoints UDP | PASS (evidência parcial; NÃO substitui TC-001 com rede bloqueada) |
| Pacote não inclui docs/tools/agent-skills/assets/sources (log do export) | PASS |
| Audacity abre e segue em execução 8 s | PASS (edição/exportação de áudio é manual na interface: NOT_RUN) |
| Rig/animação no glb, múltiplas texturas; instalação em máquina limpa; FPS | NOT_RUN |
| MCPs (Godot/Blender) | NÃO instalados: necessidade não existe (ADR em TOOLS_AND_MCPS.md) |

Problemas encontrados e corrigidos: (1) `krita.exe` não gera saída na CLI; solução: usar `krita.com`. (2) Documentação com caminhos corrompidos por escapes do Python; corrigida e verificada sem caracteres de controle. (3) `Remove-Item` em `%TEMP%` bloqueado pelo ambiente; temporários deixados em `C:\Ferramentas\*\_download`.
Gate de Ambiente (PDF §18, fase 1): APROVADO para o escopo testado; itens NOT_RUN acima seguem pendentes.
