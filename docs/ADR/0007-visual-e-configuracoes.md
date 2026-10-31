# ADR-0007 — Visual 3D, Astralis, mapa e configuracoes graficas (Fase 4)

Status: aceito (2026-10-31). Visual em PRIMEIRA PASSAGEM; aprovacao de fidelidade pendente do dono.

## Modelos
- Procedurais em Blender 5.2.3 (`tools/blender/*.py`): malhas de primitivas com materiais da paleta do PDF, esqueleto de 11 ossos, skinning rigido (peso 1.0) e os 8 clipes do contrato: idle, run, jump, fall, land, special, hurt, celebrate (idle/run/celebrate com laco via sufixo `-loop`). `.blend` originais em `assets/sources/` (Git LFS).
- Exportados em glTF 2.0 (.glb); importados no Godot com esqueleto + AnimationPlayer. Orcamento: <= 4000 triangulos e <= 12 materiais por heroi (medido: 2154 a 2854). Astralis: 2066 triangulos.
- LIMITES: sem skinning suave, sem rig facial, sem expressoes; qualidade bem abaixo da arte conceitual (renders em `docs/visual/`). NAO e o modelo final.

## Separacao visual x fisica
`HeroVisual` e filho do corpo, sem colisao; estado -> clipe por tabela; virar = girar 180 graus em Y (nunca `scale.x = -1`); pes alinhados com a base da capsula. Trocar de heroi troca o modelo.

## Configuracoes graficas
- Arquivo PROPRIO `user://settings.json` (nao no save): "Nova Aventura" nao as apaga. Escrita atomica; valores invalidos voltam ao padrao.
- Perfis Baixo/Medio/Alto controlam so o que existe no renderizador Compatibility: MSAA 3D, escala de renderizacao 3D, sombras da luz principal, escala de particulas; alem de limite de FPS e vsync.
- Sem tremor de camera nem flashes no jogo: nada a reduzir ainda (acessibilidade de movimento continua pendente para quando existirem).

## Mapa Galactico Vivo
Estado derivado do save por funcao pura (`GalaxyState`); nada guardado a parte. Bloqueado ate a semente anterior ser destruida; disponivel = sem progresso; em perigo = com progresso; salvo = semente destruida. Raiz de Caeldron some so quando a semente do planeta e destruida. Modo QA (so em build de desenvolvimento, F9) mostra os 7 estados em memoria sem tocar o save.
