# ADR-0002 — Renderizador inicial: GL Compatibility

Status: aceito provisoriamente (2026-10-31); revisar após medição.
Contexto: PDF §14 manda escolher o renderizador pelo hardware real e documentar diferenças. A única máquina disponível tem Intel UHD 620 (OpenGL 3.3 no driver 27.20.100.8681) e 8 GB de RAM.
Evidência: o Godot abriu a cena de teste em janela e reportou `OpenGL API 3.3.0 ... Compatibility ... Intel(R) UHD Graphics 620`. Forward+ e Mobile NÃO foram testados (NOT_RUN).
Decisão: usar `gl_compatibility` como baseline; é o piso de compatibilidade.
Consequências: recursos exclusivos de Forward+ (ex.: SDFGI, VoxelGI) não podem ser pressupostos. Comparar com Mobile/Forward+ na Fase 4 e medir FPS reais (1% low) antes de qualquer promessa de 60 FPS.
