class_name ExtensionPlans
extends RefCounted
## Escolhe e ordena as pecas do trecho extra de cada fase: o numero da fase gira a ordem (cada fase tem receita propria) e a dificuldade cresce com ele.
## O trecho tem pelo menos o comprimento original da fase (a fase fica ~2x maior) e termina quando atinge esse tamanho.

const ORDER: Array[StringName] = [&"hops", &"patrol", &"climb", &"rupture", &"barrier", &"glide"]


static func fill(c: ExtCursor, level_id: StringName, original_length: float) -> void:
	var hard: float = clampf(float(c.number - 1) / 35.0, 0.0, 1.0)
	var count: int = 0
	while c.x - c.start_x < original_length:
		var piece: StringName = ORDER[(c.number + count) % ORDER.size()]
		match piece:
			&"hops": ExtensionPieces.hops(c, 3 + int(hard * 4.0), 2.4 + hard * 0.8)
			&"patrol": ExtensionPieces.patrol(c, 2 + int(hard * 2.0))
			&"climb": ExtensionPieces.climb(c)
			&"rupture": ExtensionPieces.rupture(c, 3 + int(hard * 3.0))
			&"barrier": ExtensionPieces.barrier(c)
			&"glide": ExtensionPieces.glide(c)
		count += 1
		if count % 2 == 0:
			ExtensionPieces.rest(c)
