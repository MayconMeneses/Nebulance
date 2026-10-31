# ADR-0009 — Feixes, prismas e mecanismos de Cristalia

Status: aceito (2026-10-31).

- **Feixes em grade, sem ray tracing** (PDF §09): `BeamSolver` e uma funcao pura sobre celulas inteiras do plano XY. Prisma '/' mapeia (dx,dy)->(dy,dx); '\' mapeia (dx,dy)->(-dy,-dx). O feixe para em bloqueio, alvo, borda ou no limite de 96 passos (anti-laco). Deterministico: mesma entrada, mesma saida (testado).
- `BeamField` recalcula a cada quadro e so redesenha quando os segmentos mudam. O estado dos cristais e DERIVADO dos prismas e dos emissores (nada guardado a parte); o checkpoint restaura os prismas (`capture/restore`).
- `BeamPrism` (E gira entre '/' e '\'), `LightBridge` (ponte/portao movido pela luz; aceita varios alvos: E logico), emissor opcionalmente ligado por um `Mechanism` (dispositivo aereo).
- **Mecanismos sincronizados**: `Mechanism.hold_time` desativa apos N s, a menos que o `MechanismGate` o trave ao abrir (todos ativos ao mesmo tempo).
- **S02**: `SequenceLock` + `SequenceCrystal`: ordem fixa (2,0,3,1), errar zera, dica que pisca em sequencia (deterministica), bau trancado ate completar.
- **Zythra** reaproveita a arquitetura de Vyrkan (`stage_keys` sobrescrevivel): etapa 1 prisma, etapa 2 flor real x ilusoes (a real nao pisca; errar tira 1 coracao e reinicia o ciclo), etapa 3 planeio de Pipa; depois Golpe Triade. Evidencia visual usada pelo bot e por TC-034.
- Viagem pelo mapa abre a proxima fase PRINCIPAL nao concluida do planeta escolhido (`LevelCatalog.next_for`).
