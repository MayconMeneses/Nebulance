# TOOLS_AND_MCPS

Nenhuma Skill, MCP ou IA é dependência do jogo. Estado em 2026-10-31.

## Instalado nesta fase
| Item | Origem | Versão | Risco | Autorização | Rollback |
|---|---|---|---|---|---|
| Godot (padrão, sem .NET) | GitHub oficial godotengine/godot | 4.7.2-stable | Baixo | PDF §15 + pedido do dono | apagar `C:\Ferramentas\Godot\` |
| Godot export templates | idem | 4.7.2-stable | Baixo | idem | apagar `%APPDATA%\Godot\export_templates\4.7.2.stable` |
| Blender (portátil) | download.blender.org | 5.2.3 LTS | Baixo | idem | apagar `C:\Ferramentas\Blender\` |
| Krita (portátil) | download.kde.org | 6.0.4.1 | Baixo | idem | apagar `C:\Ferramentas\Krita\` |
| Audacity (portátil) | GitHub audacity/audacity | 4.0.1 | Baixo | idem | apagar `C:\Ferramentas\Audacity\` |

## MCPs
| MCP | Decisão | Motivo |
|---|---|---|
| Godot MCP Bridge / Enhanced | NÃO INSTALADO | Necessidade NÃO existe: Godot, Blender e Krita foram operados por CLI/script e o pipeline completo passou nos testes. A CLI do Godot (`--headless`, `--script`, `--import`) cobre criação, testes e import. Nível Médio (npx executa código de terceiros). Reavaliar só se a CLI se mostrar insuficiente. |
| Blender Lab MCP | NÃO INSTALADO | Nível Alto (executa Python gerado). Só com VM/sandbox e aprovação específica. |

## Plugins de teste
- GdUnit4: NÃO adicionado. A Fase Zero usa um runner headless próprio (`tests/run_tests.gd`, ~60 linhas, sem dependência). Reavaliar na Fase 2 (auditar versão/licença antes).

## Skills locais do projeto (`agent-skills/`)
Criadas 6 (formato validado por `tests/unit/skills_checks.gd`): game-production-orchestrator, godot-game-architecture, platformer-controls-and-feel, blender-godot-asset-pipeline, gameplay-qa-regression, game-security-release. As outras 6 do PDF §16 (character-rig-animation, level-design-planet-bible, boss-encounter-design, game-economy-persistence, cinematic-audio-ui, game-accessibility-performance) serão criadas quando a fase correspondente começar. Skills de terceiros: nenhuma instalada.
