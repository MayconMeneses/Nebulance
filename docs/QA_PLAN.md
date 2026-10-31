# QA_PLAN — matriz TC-001..040 (PDF §18)

Estado em 2026-10-31. Comando: `Godot --headless --path . --script res://tests/run_tests.gd` (197 checagens). PASS = automatizado e executado; PARCIAL = parte coberta; NOT_RUN = não executado.

| TC | Critério | Estado | Evidência / limite |
|---|---|---|---|
| 001 | Abrir sem internet | PARCIAL | build exportado joga a fase inteira com 0 conexões TCP/UDP observadas; NÃO testado com rede bloqueada |
| 002 | Menu por teclado/controle e retomar campanha | PARCIAL | foco por teclado (seta pula itens desativados), Continuar recupera o perfil; gamepad físico NOT_RUN |
| 003 | Trocar herói mantendo vidas/corações | PASS | suite_swap (inclui entrada real Q/R pelo InputMap) |
| 004 | Troca inválida sem softlock | PASS | suite_swap; mutação → FAIL |
| 005 | Coyote time e jump buffer | PASS | suite_controller; mutação → FAIL |
| 006 | Investida só em marcados | PASS | suite_abilities; mutação → FAIL |
| 007 | Zuri salto duplo/escalada | PASS | suite_abilities; mutação (sem salto duplo) → o bot para no muro |
| 008 | Pipa planeio limitado e vento | PASS | suite_abilities; mutação (sem vento) → o bot não alcança o segredo |
| 009 | Dano com invulnerabilidade | PASS | suite_vitals; mutação → FAIL |
| 010 | 5 vidas e 3 corações (Aventura) | PASS | valores dos 3 perfis; seleção de dificuldade na interface NÃO existe |
| 011 | Abismo consome 1 vida e reaparece | PASS | suite_vitals e suite_level (ponte) |
| 012 | Zerar vidas reinicia só a fase | PARCIAL | sinal de reinício, reset da sessão e dos mecanismos; "sem apagar progresso" depende de o perfil só ser gravado ao concluir (sem teste dedicado) |
| 013 | Checkpoint reverte estados de puzzle | PASS | suite_level: moedas, barreira e inimigo voltam ao snapshot; mutação (sem restauração) → FAIL |
| 014 | Portal leva ao segredo e volta | NOT_RUN | portais não implementados |
| 015 | Baú de fase sempre entrega recompensa | PASS | suite_economy, suite_level, suite_flow |
| 016 | Baú repetido não duplica | PASS | ledger, ida e volta do save, fluxo; mutação → FAIL |
| 017 | Bronze→Ouro credita a diferença | PASS | suite_economy |
| 018 | Loja recusa saldo insuficiente | NOT_RUN | loja não existe |
| 019 | Cosmético não altera atributos | NOT_RUN | cosméticos não equipáveis |
| 020 | Salvar, fechar, reabrir | PASS | suite_save e suite_flow, incluindo SEGUNDO PROCESSO que reabre o save |
| 021 | Save inválido preserva backup | PASS | suite_save e suite_flow; mutação (sem backup) → FAIL. Disco cheio/permissão: NOT_RUN |
| 022 | Trocar dificuldade sem perder campanha | NOT_RUN | sem seleção de dificuldade |
| 023 | Reatribuição de comandos e gamepad | NOT_RUN | não implementado |
| 024 | Redução de tremor/flashes/legendas/contraste | NOT_RUN | não implementado |
| 025 | Saltar cutscene mantém recompensa | PARCIAL | só a introdução (pular não concede nem perde nada); sem outras cutscenes |
| 026–036 | mapa, bosses, final, pós-jogo | NOT_RUN | não implementados |
| 037 | Exportar e iniciar fora do editor | PARCIAL | build roda e o bot completa a fase no build; sem instalação em máquina limpa |
| 038 | Export sem rede/IA/MCP | PARCIAL | 0 conexões; `tests/` ainda vai no pacote (gancho --bench); inventário final pendente |
| 039 | Perfis gráficos baixo/médio/alto | NOT_RUN | não existem perfis |
| 040 | Auditoria de licenças | PARCIAL | docs/ASSET_LICENSES.md cobre assets de teste e o áudio gerado |

Playtest humano, gamepad físico e hardware-alvo: NOT_RUN.

Benchmark de JOGO REAL (dev, NÃO é o alvo; bot joga a fase 01 com HUD e áudio; Intel UHD 620; gl_compatibility):
- build exportado: 1086 quadros, média 59,0 FPS, 1% low 59,5 FPS, pior quadro 145,4 ms (travamento único aparente);
- projeto no editor (sem export): 1070 quadros, média 58,2 FPS, 1% low 48,3 FPS, pior quadro 141,8 ms.
Taxa do monitor/vsync não verificada. Não prova 60 FPS em hardware-alvo.

## Atualizacao Fases 4 e 5 (suite completa: 328 checagens)
- TC-013 PASS tambem nas fases 02 e 03 (estabilizador, plataformas, mecanismos e portao voltam ao snapshot).
- TC-014 PASS: portal com origem/destino/retorno, estado de origem preservado, repeticao sem duplicar (fase 03 -> S01).
- TC-039 PARCIAL: perfis Baixo/Medio/Alto existem e o bot completa a fase 01 nos tres no build exportado (sem quebra funcional); desempenho medido abaixo.
- TC-026 PARCIAL: mapa mostra so rotas disponiveis e contagem (sem spoilers) em 7 estados de QA; segredos conhecidos por contagem.
- TC-025 PARCIAL: introducao com a Astralis 3D pulavel a qualquer momento sem efeitos.

Benchmark por perfil (build exportado, Intel UHD 620, gl_compatibility, bot joga a fase 01 com HUD/audio/efeitos; NAO e o hardware-alvo):
| Perfil | Com vsync: media / 1% low | Sem vsync: media / 1% low |
|---|---|---|
| Baixo | 57,5 / 45,2 | 137,7 / 94,0 |
| Medio | 58,0 / 40,1 | 69,3 / 57,3 |
| Alto | 54,9 / 38,0 | 70,6 / 51,4 |
Pior quadro ~145-150 ms em todas as execucoes (travamento unico no inicio, provavelmente compilacao de shaders; cache frio/quente NAO separados). 60 FPS estaveis NAO foram atingidos em Medio/Alto com vsync nesta maquina.

## Atualizacao Sylvara completa (suite: 365 checagens)
- TC-025 PARCIAL: introducao da Astralis e reacao de Caeldron pulaveis (a reacao tambem nao concede nada).
- TC-026 PARCIAL: mapa mostra Sylvara salvo e Cristalia disponivel (so em producao) apos vitoria real e nos 7 estados de QA.
- TC-027 PASS: a semente e uma transacao unica; Caeldron reage 1x (so em `first_time`); salvo na hora; repetir nao duplica. Mutacao (sem checagem) -> FAIL.
- TC-028 PASS (parcial): semente restaura o estado do planeta no mapa (raiz removida, proxima rota) e liberta o guardiao no save; o chefe nunca ressuscita (mutacao -> FAIL). NAO ha restauracao visual do planeta nem cutscene de libertacao.
- TC-029 PASS: Vyrkan (padroes, aviso >= 0,6 s, so a erupcao ativa fere, etapas por mecanismo certo, Golpe Triade com 3 herois diferentes). Mutacoes (sem telegraph; Triade desativado) -> FAIL.
- TC-013 PASS tambem nas fases 04 (onda de raizes, plataformas moveis) e 06.
- TC-030..036 (outros chefes/final): NOT_RUN.
