# ADR-0006 — Salvamento, economia e fluxo (Fase 3)

Status: aceito (2026-10-31).

## Salvamento
- JSON em `user://saves/slot1.json`, pasta fixada por `config/use_custom_user_dir` + `custom_user_dir_name="Nebulance"` (`%APPDATA%\Nebulance`). O nome do projeto contém ":" e NÃO é usado no caminho.
- Esquema `SaveGameV1` (`SaveData`): só chaves String; inteiros normalizados após o parse (JSON devolve float); validação de tipo e faixa. Nunca executa conteúdo do save.
- Escrita: arquivo `.tmp` → releitura e validação → cópia do save válido atual para `.bak` → substituição. O `.bak` só recebe um save que valida (um principal corrompido nunca vira backup).
- Carga: principal válido → OK; inválido → backup (RECOVERED_FROM_BACKUP, arquivos intactos); ambos inválidos → CORRUPT (arquivos preservados); versão maior → FUTURE_VERSION e somente leitura (impede sobrescrever).
- "Nova Aventura" move o save atual para `.old-N` (nunca apaga) e exige confirmação se já existir save.
- Estado de TENTATIVA (vidas/corações da fase) NÃO é persistido nesta fase.

## Economia
Ver docs/ECONOMY.md. `RewardLedger` é a única porta de crédito; transações idempotentes por ID; critérios de classificação são desenho próprio (classe B).

## Fluxo e estrutura
- `GameFlow` (cena principal) dono do perfil e do save: MainMenu → Level (+ introdução pulável) → Results → MainMenu. Sem autoloads (dependências passadas explicitamente).
- `LevelController` por fase: coletas, snapshot/restauração (grupo `snapshotable`), baú e conclusão. Mecanismos (barreira, coletável, inimigo) implementam `capture()/restore()`.
- O fluxo roda em `PROCESS_MODE_ALWAYS` (menu/pausa); a fase é marcada PAUSABLE explicitamente (bug encontrado e corrigido por teste).
- Gancho de desenvolvimento: `--bench` (só se `tests/scenes/bench.tscn` existir no pacote). A versão de release final deve excluir `tests/`.

## Limites conhecidos
Sem falha de disco cheio/permissão simulada (NOT_RUN). Introdução, HUD, menu e áudio são provisórios. Gamepad não testado fisicamente.
