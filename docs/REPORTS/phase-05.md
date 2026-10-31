# RELATORIO - FASE 5 / Producao dos planetas (Sylvara implementada; planetas 2 a 6 pendentes)
Data: 2026-10-31 | Suite completa: 365 checagens, 0 falhas, 0 erros de script.

## Escopo honesto
O PDF proibe produzir as 42 fases em lote. Esta etapa entrega Sylvara completa em graybox (fases 01 a 06 + S01 + chefe Vyrkan) com bots, e a base reutilizavel. NAO entregues: Cristalia, Mecatron, Aquarys, Aerion, Umbraxis (36 fases, 5 chefes, 5 secretas), Caeldron/final.

## Entregue (executado)
Base: `LevelScene`, `LevelCatalog`, mecanicas (plataforma de ruptura, movel, mecanismo, portao, onda de raizes), gravidade localizada, portal com retorno consistente, resgate. Fases: 02 (ponte), 03 (floresta + portal), S01, 04 (rio), 05 (torre), 06 (Vyrkan). Chefe: 3 fases, Golpe Triade, camera de arena. `ProgressLedger.commit_seed` (transacao unica, salva na hora), reacao de Caeldron, mapa atualizado (Sylvara salvo, Cristalia disponivel). ADR-0008.

## Testes
Cada fase tem bot que a completa sem teleporte (Ouro nas 02-05; chefe: 6 moedas, 0 vidas perdidas). TC-013, 014, 027, 028, 029 PASS. Mutacoes: estabilizador, semente sem checagem, sem telegraph, restore sem save, Triade desativado: todas falham os testes.

## Bugs encontrados por teste e corrigidos
1. Onda de raizes criada depois do setup do controller nao reiniciava ao morrer (nao entrava no snapshot). Corrigido (nasce com a geometria); o mesmo cuidado foi aplicado ao chefe e ao Triade.
2. Pausa/foco do menu, runner isolado e bench (fases anteriores).
3. Teste "Continuar" jogava a fase errada apos "proxima fase nao concluida": parametro de fase.
4. Controller passou de 200 linhas: consultas de zona extraidas para `ZoneEffects`.

## Pendente / nao verificado
Playtest humano (diversao, dificuldade, duracao de todas as fases e do chefe); calibracao do chefe; arte/modelos finais (Vyrkan e arena sao graybox); cutscene de libertacao e restauracao visual do planeta; mordidas/armadilhas de sementes de Vyrkan; compartimento selado da Astralis; pista pos-restauracao (fase 04); texto do holograma (fase 05); atalho com Pipa (fase 02); planetas 2 a 6.
Gate "Primeira vitoria" (PDF): Sylvara testada integralmente por bot; "playtests de dificuldades e controles" NOT_RUN -> APROVADO PARCIAL (depende do playtest do dono).
