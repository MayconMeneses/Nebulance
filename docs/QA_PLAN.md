# QA_PLAN — matriz TC-001..040 (PDF §18)

Estado em 2026-10-31. Comando: `Godot --headless --path . --script res://tests/run_tests.gd` (102 checagens). PASS = automatizado e executado; PARCIAL = parte coberta; NOT_RUN = não executado.

| TC | Critério | Estado | Evidência / limite |
|---|---|---|---|
| 001 | Abrir sem internet | PARCIAL | build roda 10 s sem conexões TCP/UDP; NÃO testado com rede bloqueada |
| 002 | Menu por teclado/controle | NOT_RUN | não há menu |
| 003 | Trocar herói mantendo vidas/corações | PASS | suite_swap (8 checagens: solo, ar, intenção, HURT) |
| 004 | Troca inválida sem softlock | PASS | suite_swap; mutação sem validação → FAIL (detectada) |
| 005 | Coyote time e jump buffer | PASS | suite_controller; mutação coyote=0 → FAIL |
| 006 | Investida só em marcados | PASS | suite_abilities (marcado, comum, não marcado, outros heróis); mutação → FAIL |
| 007 | Zuri salto duplo/escalada | PASS | suite_abilities. Hitbox "correta" só validada por forma (cápsula), sem playtest |
| 008 | Pipa planeio limitado e vento | PASS | suite_abilities (limite 1,5 s, vento determinístico) |
| 009 | Dano com invulnerabilidade | PASS | suite_vitals; mutação sem invulnerabilidade → FAIL |
| 010 | 5 vidas e 3 corações (Aventura) | PASS | valores dos 3 perfis; seleção de dificuldade na interface NÃO existe |
| 011 | Abismo consome 1 vida e reaparece | PASS | suite_vitals (abismo e zerar corações) |
| 012 | Zerar vidas reinicia só a fase | PARCIAL | sinal de reinício e reset de vitais testados; "sem apagar progresso" depende de save (não existe) |
| 013–036 | puzzles, portais, baús, loja, save, acessibilidade, mapa, bosses, final | NOT_RUN | não implementados |
| 037 | Exportar e iniciar fora do editor | PARCIAL | build exportado roda e fecha com exit 0; sem instalação em máquina limpa |
| 038 | Export sem rede/IA/MCP | PARCIAL | 0 conexões observadas; inventário de dependências ainda não feito |
| 039 | Perfis gráficos baixo/médio/alto | NOT_RUN | não existem perfis |
| 040 | Auditoria de licenças | PARCIAL | docs/ASSET_LICENSES.md cobre só os assets de teste |

Playtest humano, gamepad físico e hardware-alvo: NOT_RUN.
Benchmark (dev, NÃO é o alvo): build exportado, Intel UHD 620, gl_compatibility, graybox do playground, 15 s: 901 quadros, média 60,0 FPS, 1% low 60,0 FPS, pior quadro 16,7 ms. Provável limite de vsync a 60 Hz (taxa do monitor não verificada); não prova folga de desempenho.
