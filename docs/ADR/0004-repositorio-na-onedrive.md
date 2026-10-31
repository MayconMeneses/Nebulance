# ADR-0004 — Repositório mantido na pasta OneDrive

Status: decidido pelo dono (2026-10-31).
Contexto: o projeto está em `C:\Users\maico\OneDrive\Área de Trabalho\Jogo`. A OneDrive sincroniza `.git/` e `.godot/`, o que pode travar ou corromper o repositório e o cache do Godot. O PDF sugere uma pasta fora de sincronização (ex.: `D:\Projetos\Nebulance`).
Decisão: manter o repositório onde está.
Riscos aceitos: conflitos de sincronização em `.git/`, bloqueio de arquivos durante import/commit, cache `.godot/` sincronizado sem necessidade.
Mitigações recomendadas (não aplicadas): excluir `.godot/` e `build/` da sincronização; manter cópia do repositório fora da OneDrive (`git clone` ou `git bundle`) como backup; não rodar Git e Godot enquanto a OneDrive sincroniza muitos arquivos.
Reversão: mover a pasta inteira e atualizar os caminhos em `README.md` e `docs/ENVIRONMENT.md`.
