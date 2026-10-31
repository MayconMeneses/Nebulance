---
name: godot-game-architecture
description: Guarda a arquitetura modular do Nebulance (Godot 4.7.2, GDScript tipado) e impede God Files; usar ao criar ou refatorar cenas e scripts.
---
1. Consultar a estrutura em game/ e os contratos do PDF secao 12 (GameFlow, ActorController, AbilityComponents, LevelController, RewardLedger, SaveService...).
2. Um script = uma responsabilidade; sinais para comunicar; autoloads minimos; dados em Resource (.tres), nunca constantes espalhadas.
3. Nenhuma logica de gameplay acoplada a caminho interno de mesh importada.
4. Checar tamanho: nenhum .gd acima de 200 linhas sem justificativa em ADR (comando: contar linhas por arquivo).
5. Registrar decisoes relevantes em docs/ADR/.
