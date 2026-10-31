# RELATORIO - FASE 4 / Qualidade visual e Astralis
Data: 2026-10-31 | Ambiente: Windows, i5-8265U, Intel UHD 620, 8,43 GB; Godot 4.7.2 (gl_compatibility); Blender 5.2.3.

## Entregue (executado)
Modelos 3D de Rocco, Zuri e Pipa (Blender: malhas, esqueleto de 11 ossos, 8 clipes) e da Astralis; `HeroVisual` (estado->clipe, giro de 180 graus); renders de conferencia em docs/visual/ (enviados ao dono); apresentacao 3D da Astralis na chegada (pulavel a qualquer momento); Mapa Galactico Vivo (estado derivado, raizes, painel sem spoilers, modo QA); configuracoes graficas Baixo/Medio/Alto + FPS + vsync em arquivo proprio; efeitos de particulas por perfil; benchmark por perfil. ADR-0007.

## Testes (suite completa: 328 checagens, 0 falhas)
visual (41), configuracoes (14), mapa (18), Astralis (14), efeitos (7). O visual nao mudou o gameplay (bot da fase 01 segue Ouro).

## Honestidade sobre qualidade
Os modelos sao de PRIMEIRA PASSAGEM, procedurais e quadrados; o Rocco lembra um robo-cachorro e a Zuri e rigida. NAO correspondem a qualidade da arte conceitual. Aprovacao do dono: pendente (renders enviados).

## Problemas encontrados e corrigidos
Nomes de malha colidindo com ossos (Godot renomeava para leg_l_2): renomeei as malhas. Gancho de teste dos renders (enquadramento, tamanho da janela). Menu: item Configuracoes ativado (teste de foco atualizado). Resultados de testes "PASS" mascaravam `SCRIPT ERROR`: passei a contar erros de script em toda verificacao.

## Nao verificado / pendente
Fidelidade visual (dono); rig facial/expressoes; skinning suave; cache de shaders frio x quente e o travamento de ~145 ms; 60 FPS em hardware-alvo; acessibilidade de movimento (nao ha tremor/flash ainda); decolagem/tunel de viagem; interior da Astralis; perfis testados so na fase 01.
Gate Fase 4 (PDF): desempenho validado em dev (nao no alvo); gate NAO aprovado integralmente.
