# NEBULANCE: As Sementes do Colapso

Plataforma 2.5D offline para Windows (Godot 4.7.2, GDScript tipado). Especificação: PDF "Prompt Mestre Supremo" (fora do repositório). Versão do jogo: **0.4.0** (`game/core/game_version.gd`, igual ao `AppVersion` do instalador).

## Estado (2026-11-03)
**Todas as 42 fases existem em graybox** (36 principais em 6 planetas + 6 secretas), cada uma com um bot automatizado que a completa sem teleporte e uma suite de testes; os 6 chefes (Vyrkan, Zythra, Ferrorraiz, Thalassa, Zefrion, Necryon) estão implementados. A regressão completa informada nos merges mais recentes da `main` é de **792 checagens, 0 falhas**.

**Isto NÃO é um jogo pronto.** Falta ou não foi validado:
- visual e áudio são provisórios (caixas coloridas e modelos de primeira passagem); nenhuma fase passou por playtest humano, então duração, ritmo e dificuldade não estão calibrados;
- não há final (Caeldron não morre), cutscenes de libertação, restauração visual dos planetas, loja, cosméticos equipáveis nem seleção de dificuldade na interface;
- Umbraxis (planeta 6) ainda não é jogável no mapa, embora suas fases existam e passem nos testes;
- **60 FPS em hardware-alvo NÃO foi validado** (medidas antigas, só da fase 01, em Intel UHD 620, ficaram abaixo de 60 estáveis em Médio/Alto com vsync);
- gamepad físico, controles de toque em aparelho real/Android, build e instalador da versão atual em máquina limpa: não testados;
- ao abrir, o jogo consulta o GitHub Releases em busca de atualização (ligado por padrão; desligável em Configurações; falha silenciosa; é o único uso de rede, por decisão do dono; um teste automatizado barra qualquer outro uso de rede no código do jogo).

Detalhes por requisito e por teste: `docs/REQUIREMENTS_MATRIX.md`, `docs/QA_PLAN.md`. Tabela das 42 fases e lista de desvios do design: `docs/REPORTS/phase-07-campanha.md` e `docs/LEVEL_BIBLE.md`.

## Jogar (no editor)
Abra o projeto no Godot 4.7.2 e execute (F5). Controles padrão: A/D ou setas, Espaço (pular), Shift (habilidade), Q/R (trocar herói), E (interagir), Esc (pausa); remapeáveis em Opções > Teclas. Gamepad mapeado, não testado fisicamente. Ver `docs/CONTROLS.md`.

## Rodar os testes
Caminho do Godot usado neste projeto: `C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe` (ajuste para o seu).
```
# 1) importar recursos (necessário depois de criar classes/arquivos novos)
Godot_v4.7.2-stable_win64_console.exe --headless --path . --import

# 2) regressão completa (leva vários minutos)
Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd

# 3) só algumas suites (nomes sem extensão, depois de --)
Godot_v4.7.2-stable_win64_console.exe --headless --path . -s tests/run_tests.gd -- suite_aerion_25 suite_boss_zefrion
```
A saída termina em `RESULT: PASS (N checagens, 0 falha(s))` ou `RESULT: FAIL`. Passe `--trace` depois do `--` para ver o rastro dos bots. Confira também que não há linhas `SCRIPT ERROR`.

Atenção: `assets/` usa Git LFS. Num clone/worktree sem os arquivos reais (ponteiros de ~130 bytes em `assets/models/*.glb` e `assets/audio/*.wav`) as suites que instanciam heróis imprimem `SCRIPT ERROR` por falta de modelo; rode `git lfs pull` ou copie os assets reais antes de julgar um resultado.

## Gerar o executável e o instalador (Windows)
1. Exportar o jogo com o preset "Windows Desktop" (precisa dos export templates 4.7.2 instalados). O instalador espera `build\NEBULANCE.exe` (o `export_path` salvo no preset é `build/nebulance_phase3.exe`, então passe o caminho explicitamente):
   ```
   Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-release "Windows Desktop" build/NEBULANCE.exe
   ```
2. Instalar o [Inno Setup](https://jrsoftware.org/isinfo.php) e compilar o script versionado:
   ```
   ISCC.exe installer\nebulance.iss
   ```
   Saída: `installer/Output/NEBULANCE_Setup.exe` (o `.exe` do instalador e a pasta `build/` ficam fora do git). Instalação por usuário (`PrivilegesRequired=lowest`), atalho no menu e opcional na área de trabalho, idioma pt-BR.
3. Ao mudar a versão, atualize juntos `GameVersion.CURRENT` e `AppVersion` em `installer/nebulance.iss` (há um teste, `suite_updates`, que confere) e a tag `v<versão>` do release.

Estes comandos são os padrões do Godot e do Inno Setup; não foram reexecutados na revisão de documentação de 2026-11-03.

## Documentação
`docs/`: ENVIRONMENT, TOOLS_AND_MCPS, REQUIREMENTS_MATRIX, QA_PLAN, LEVEL_BIBLE, CONTROLS, ECONOMY, ASSET_LICENSES, ASSET_PIPELINE, ADR (decisões 0001–0009) e REPORTS (relatórios por fase de trabalho, incluindo `phase-07-campanha.md`).
