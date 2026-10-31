# TOOLS_AND_MCPS

Nenhuma Skill, MCP ou IA é dependência do jogo. Estado em 2026-10-31.

## Instalado nesta fase
| Item | Origem | Versão | Risco | Autorização | Rollback |
|---|---|---|---|---|---|
| Godot (padrão, sem .NET) | GitHub oficial godotengine/godot | 4.7.2-stable | Baixo | PDF §15 + pedido do dono | apagar `C:\Ferramentas\Godot\` |

## MCPs
| MCP | Decisão | Motivo |
|---|---|---|
| Godot MCP Bridge / Enhanced | NÃO INSTALADO | Necessidade não demonstrada: a CLI do Godot (`--headless`, `--script`, `--import`) cobre criação, testes e import. Nível Médio (npx executa código de terceiros). Reavaliar só se a CLI se mostrar insuficiente. |
| Blender Lab MCP | NÃO INSTALADO | Nível Alto (executa Python gerado). Só com VM/sandbox e aprovação específica. |

## Plugins de teste
- GdUnit4: NÃO adicionado. A Fase Zero usa um runner headless próprio (`tests/run_tests.gd`, ~60 linhas, sem dependência). Reavaliar na Fase 2 (auditar versão/licença antes).

## Skills locais do projeto (`agent-skills/`)
Nenhuma criada ainda. As 11 skills sugeridas no PDF §16 continuam pendentes; serão criadas sob demanda, uma por vez, com teste de ativação.
