---
name: game-security-release
description: Audita dependencias, plugins, MCPs e o pacote exportado do Nebulance (offline, sem segredos, licencas); usar antes de instalar terceiros e antes de exportar.
---
1. Antes de instalar qualquer coisa: fonte oficial, versao fixada, hash conferido, licenca, rollback; registrar em docs/TOOLS_AND_MCPS.md.
2. Nao executar scripts baixados sem ler; MCP so com necessidade provada e aprovacao especifica.
3. Verificar .gitignore: sem tokens, builds, cache .godot.
4. Pacote exportado: sem Node/Python/MCP/chaves; funciona sem rede.
5. Registrar resultado no relatorio do marco.
