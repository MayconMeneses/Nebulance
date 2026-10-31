# ADR-0001 — Engine: Godot 4.7.2 estável, GDScript tipado

Status: aceito (2026-10-31).
Contexto: PDF §12/§15.2 exige Godot 4.x estável, GDScript, sem .NET, e pede confirmar a versão no início.
Evidência: a API do GitHub oficial devolveu `tag_name = 4.7.2-stable` como latest release; o PDF cita a mesma versão.
Decisão: travar o projeto em 4.7.2 (`config/features` = "4.7"). Atualizações de versão exigem novo ADR e rodada completa de testes.
Consequências: templates de exportação devem ser da mesma versão (4.7.2). Assinatura GPG do release não verificada.
