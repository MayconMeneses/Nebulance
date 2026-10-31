# ASSET_PIPELINE

Validado em 2026-10-31 com assets de teste (cubo, ícone, tom). Os modelos finais ainda não existem.

| Etapa | Ferramenta | Comando / regra | Saída |
|---|---|---|---|
| Modelo | Blender 5.2.3 | `blender --background --python tools/blender_make_test_asset.py -- <.blend> <.glb>` | `assets/sources/*.blend` (original, LFS) e `assets/models/*.glb` |
| Textura/UI | Krita 6.0.4.1 | `krita.com <entrada> --export --export-filename <saida>` | `assets/sources/*.kra` (original) e `assets/textures/*.png` |
| Áudio | Audacity 4.0.1 (edição manual) | exportar WAV/OGG para `assets/audio/` | arquivo-fonte e licença em docs/ASSET_LICENSES.md |
| Importação | Godot 4.7.2 | `--headless --path . --import` | verificado por `tests/unit/asset_pipeline_checks.gd` |

Regras: `assets/sources/` tem `.gdignore` (Godot não importa originais); aplicar escala/rotação antes do export; 1 unidade Godot = 1 m; nomes em snake_case; nenhum asset externo sem licença registrada.
Não validado: animações/rig/esqueleto, múltiplos materiais/texturas no glb, edição de áudio no Audacity (GUI, sem automação).
