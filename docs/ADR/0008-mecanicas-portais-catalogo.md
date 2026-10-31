# ADR-0008 — Base de fases, mecanicas, portais e catalogo (Fase 5)

Status: aceito (2026-10-31).

- `LevelScene` e a base de toda fase (ambiente, trio, camera, visual, efeitos, controller). Cada fase herda e so define definicao + geometria. `LevelCatalog` e o unico lugar que conhece os scripts das fases; `next_for` escolhe a proxima fase principal ainda nao concluida do planeta.
- Mecanicas reutilizaveis em `game/world_mechanics/`: `RupturePlatform` (solida/intangivel em ciclo deterministico, aviso antes de sumir), `Mechanism` (interativo; liga alvos por `link_id`), `MechanismGate` (abre quando TODOS os mecanismos do mesmo `link_id` estao ativos). Todos implementam `capture()/restore()` e entram no snapshot do checkpoint.
- Gravidade localizada: zonas na camada WIND com `gravity_scale` (menor multiplicador vence); consulta em `ZoneEffects`.
- Interacao generica (E): qualquer `Area3D` na camada INTERACTABLE com `can_interact/prompt/interact` (Bau, Mecanismo, Portal).
- Portal: a fase de origem fica viva (pausada e oculta); a secreta roda por cima; ao sair o heroi volta na mesma posicao, com sessao, mecanismos e portoes iguais. Portal registrado em `world.portal_ids` na primeira entrada; recompensas unicas seguem idempotentes.
- Fases secretas nao entram na ordem principal e nao contam como fases numeradas.
