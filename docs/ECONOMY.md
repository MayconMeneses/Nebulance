# ECONOMY — regras e valores (classe B: A BALANCEAR)

Estado em 2026-10-31. Todos os números abaixo são **de teste** (referência do PDF: fase comum 80, Prata até 110, Ouro até 150) e vivem em `LevelDefinition` (.tres), nunca no código.

## Regras (invariantes testadas)
- Somente moedas internas. Sem microtransações, sem sorte oculta, sem vantagem comprável.
- **Baú de conclusão** garante a recompensa da classificação (TC-015). A classificação NÃO é sorteio.
- **Repetir a fase** credita só a diferença entre a nova classificação e a melhor já recebida (TC-017); resultado igual ou menor não credita nada nem rebaixa (TC-016).
- **Moedas coletáveis** valem 1 por ID, uma única vez por perfil (transação `coin:<id>`). IDs que não pertencem à fase são ignorados.
- **Itens e memórias únicos** entram uma vez no perfil.
- **Tentativa × perfil:** coletas da tentativa ficam em `LevelSession`; checkpoint tira snapshot; morrer volta ao snapshot; o `RewardLedger` só credita ao concluir a fase. Assim, morrer e reiniciar não duplica nem perde moedas (TC-013).
- Transações usam IDs determinísticos (`coin:<id>`, `chest:<level>:<grade>`), gravados no save; idempotência sobrevive a salvar e carregar.

## Critérios de classificação (DESENHO PRÓPRIO — o PDF cita Bronze/Prata/Ouro/Lendário mas não define critérios)
| Classe | Critério |
|---|---|
| Bronze | concluir a fase |
| Prata | concluir + achar o segredo (item único ou memória) |
| Ouro | Prata + todas as moedas da fase + nenhuma vida perdida na tentativa |
| Lendário | NÃO implementado (PDF: feito extraordinário; a definir) |

## Pendente
Loja e compra (TC-018/019), cosméticos equipáveis, bônus de feitos ("Por um Triz!"), tabelas de boss e portal, calibração por playtest.
