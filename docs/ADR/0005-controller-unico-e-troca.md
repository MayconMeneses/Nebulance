# ADR-0005 — Controller único do trio, intents e regras de troca

Status: aceito (2026-10-31). Valores de movimento são iniciais e sujeitos a playtest.

## Decisões
1. **Uma única entidade controlável** (`ActorController`, CharacterBody3D). Cada herói é um `HeroProfile` (Resource: colisão, `MovementTuning`, `HeroAbility`). Sem IA de seguimento e sem três corpos.
2. **Vidas e corações ficam em `TrioVitals`** (nó separado), não no herói: são compartilhados e atravessam a troca. Dificuldade em `DifficultyProfile` (.tres).
3. **O controller não lê o `Input`.** `InputReader` converte o InputMap em `HeroIntent`; os testes injetam `ScriptedInput` quadro a quadro (determinismo para TC-005).
4. **Parâmetros em Resource** (`.tres` gerados por `tools/generate_hero_resources.gd`), nunca constantes na lógica.
5. **Camadas de colisão nomeadas** em `PhysicsLayers` e no `project.godot`: world, hero, hazard, impact_target, climbable, wind, checkpoint, abyss.
6. **Zonas** (perigo, abismo, escalável, vento, checkpoint) são `LevelZone` consultadas por sobreposição de forma (`ShapeProbe`), a cada quadro. Assim o dano é reavaliado quando a invulnerabilidade termina, sem depender de `body_entered`.

## Regras da troca (`HeroSwapper`)
- Recusada se: mesmo herói; estado SPECIAL (habilidade ativa), HURT, DEAD ou CUTSCENE; a nova cápsula, **com os pés alinhados** (+0,02 m), sobrepõe a camada `world`.
- No ar, a troca é **permitida** (fora dos estados acima). Revisar após playtest.
- Preserva posição dos pés, x, velocidade, vidas e corações. Reinicia o estado da habilidade do novo herói.

## Habilidades (iniciais)
Rocco: investida que só aciona alvos no grupo `impact_target`. Zuri: salto duplo (1 por voo) e escalada só em `CLIMBABLE`. Pipa: planeio com duração (1,5 s) e queda máxima 2 m/s; `WIND` dá sustentação.
Pendentes (não implementados): empurrar objetos e latido de Rocco, rajada de asas e bicada de Pipa, esquiva e interpretação de registros de Zuri.

## Fora de escopo desta fase
Persistência (TC-012 só parcial), mecanismos de fase, animações, modelos finais, gamepad testado em hardware.
