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
| Blender | INSTALADO (portátil) | 5.2.3 LTS, `C:\Ferramentas\Blender\blender-5.2.3-windows-x64\blender.exe`; zip oficial download.blender.org, SHA-256 = publicado |
| Krita | INSTALADO (portátil) | 6.0.4.1, `C:\Ferramentas\Krita\krita-x64-6.0.4.1\bin\krita.com` (usar `.com` na CLI); zip oficial download.kde.org, SHA-256 = `.sha256` publicado |
| Audacity | INSTALADO (portátil) | 4.0.1, subpasta de `C:\Ferramentas\Audacity\app\`; 7z oficial GitHub audacity/audacity, SHA-256 = CHECKSUMS.txt |
| Export templates Godot | INSTALADOS | 4.7.2.stable em `%APPDATA%\Godot\export_templates\4.7.2.stable\` (35 arquivos); `.tpz` com SHA-512 = publicado |
| `pdftotext` | presente (vem junto do Git for Windows) | usado para ler o PDF |

## Procedência do Godot
- Fonte: GitHub oficial `godotengine/godot`, release `4.7.2-stable`, asset `Godot_v4.7.2-stable_win64.exe.zip` (86.013.866 bytes).
- Verificação: SHA-512 calculado = SHA-512 publicado em `SHA512-SUMS.txt` do mesmo release.
  `83decd58fdf67b9d657958a1ae6bf1929c20785315a81effe245874cdc57acb709bf868e00778a96984338c1b29dafdb453c6847747694621c6ecf5da2259993`
- Assinatura/GPG do release: NÃO verificada.
- Rollback: apagar `C:\Ferramentas\Godot\`, `Blender`, `Krita`, `Audacity` e `%APPDATA%\Godot\export_templates\4.7.2.stable` (nada global foi alterado: sem instalador, sem PATH, sem registro).

## Comandos de verificação
```
C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe --version
C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/run_tests.gd
```

## Observações
- Todas as ferramentas são portáteis (zip/7z): sem instalador, sem administrador, sem PATH, sem registro.
- Assinaturas GPG/Authenticode NÃO verificadas; só os hashes publicados pelos próprios sites oficiais.
- `Remove-Item` em `%TEMP%` é bloqueado pelo ambiente; os temporários ficam em `C:\Ferramentas\*\_download` (podem ser apagados pelo dono).
