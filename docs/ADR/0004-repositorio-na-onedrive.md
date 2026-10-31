# ADR-0004 — Repositório na pasta "OneDrive" (sem sincronização ativa)

Status: decidido pelo dono (2026-10-31).
Contexto: o projeto está em `C:\Users\maico\OneDrive\Área de Trabalho\Jogo`. Se a OneDrive sincronizasse a pasta, `.git/` e `.godot/` poderiam travar ou corromper. O PDF sugere uma pasta fora de sincronização.
Evidência: o dono informou que a OneDrive está desativada. Verificado por comando: nenhum processo `OneDrive.exe` em execução, nenhuma conta em `HKCU:\Software\Microsoft\OneDrive\Accounts\Personal`, nenhuma entrada de inicialização da OneDrive.
Decisão: manter o repositório onde está. O nome "OneDrive" no caminho é só um diretório comum.
Riscos residuais: se a OneDrive for reativada, a sincronização passa a atingir `.git/` e `.godot/`. Nesse caso, excluir `.godot/` e `build/` da sincronização ou mover o repositório.
Backup: sem sincronização, o repositório local é a única cópia. Fazer `git bundle` ou clone para outro disco em cada marco.
