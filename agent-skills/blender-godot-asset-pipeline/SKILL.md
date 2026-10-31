---
name: blender-godot-asset-pipeline
description: Pipeline Blender para Godot (.blend original, export .glb, import e checagem de escala/materiais/animacoes); usar ao produzir ou importar modelos.
---
1. Manter o .blend original em assets/sources/ (Git LFS); exportar .glb 2.0 para assets/models/.
2. Aplicar escala e orientacao; nomear malhas, materiais e esqueleto; sem modificadores quebrados.
3. Importar na Godot e inspecionar escala, rotacao, skeleton, normais, materiais e animacoes.
4. Criar cena wrapper com colisao, script e som; nao acoplar logica ao caminho interno da mesh.
5. Registrar origem e licenca em docs/ASSET_LICENSES.md. Blender via GUI/CLI; sem MCP de Blender.
