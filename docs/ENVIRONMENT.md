# ENVIRONMENT — Fase Zero

Data: 2026-10-31. Todos os valores abaixo foram observados por comando nesta sessão.

## Hardware / SO (máquina de desenvolvimento)
| Item | Valor observado |
|---|---|
| SO | `Get-ComputerInfo`: "Windows 10 Home Single Language", 64 bits (o ambiente da sessão reporta build 10.0.26300, tratada como Windows 11; divergência não investigada) |
| CPU | Intel Core i5-8265U @ 1.60 GHz |
| GPU | Intel UHD Graphics 620, driver 27.20.100.8681 (OpenGL 3.3 observado pelo Godot) |
| RAM | 8,43 GB (8434282496 bytes) |
| Disco C: | 171,6 GB usados / 50,9 GB livres |

Esta máquina é modesta: serve como piso de desempenho (ver ADR-0002), mas NÃO foi eleita máquina-alvo de homologação (decisão pendente do dono).

## Ferramentas
| Ferramenta | Estado | Versão / origem |
|---|---|---|
| Godot | INSTALADO | 4.7.2-stable (`4.7.2.stable.official.ed1daf0bf`), edição padrão sem .NET, em `C:\Ferramentas\Godot\` |
| Git | presente | 2.55.0.windows.5 |
| Git LFS | presente | 3.7.1 |
| Node.js / npm | presente | v24.20.0 / 11.19.0 (não usados pelo jogo) |
| Python | presente | 3.14.7 (usado só para extrair imagens do PDF; não é dependência) |
| Blender | AUSENTE (NOT_RUN) | a instalar na fase de ambiente 1 |
| Krita | AUSENTE (NOT_RUN) | idem |
| Audacity | AUSENTE (NOT_RUN) | idem |
| Export templates Godot | AUSENTES (NOT_RUN) | idem |
| `pdftotext` | presente (vem junto do Git for Windows) | usado para ler o PDF |

## Procedência do Godot
- Fonte: GitHub oficial `godotengine/godot`, release `4.7.2-stable`, asset `Godot_v4.7.2-stable_win64.exe.zip` (86.013.866 bytes).
- Verificação: SHA-512 calculado = SHA-512 publicado em `SHA512-SUMS.txt` do mesmo release.
  `83decd58fdf67b9d657958a1ae6bf1929c20785315a81effe245874cdc57acb709bf868e00778a96984338c1b29dafdb453c6847747694621c6ecf5da2259993`
- Assinatura/GPG do release: NÃO verificada.
- Rollback: apagar `C:\Ferramentas\Godot\` (pasta exclusiva; nada global foi alterado, sem instalador, sem PATH, sem registro).

## Comandos de verificação
```
C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe --version
C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
```
