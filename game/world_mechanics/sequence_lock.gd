class_name SequenceLock
extends Node3D
## Fechadura de SEQUENCIA (S02): os cristais precisam ser acionados numa ordem fixa e deterministica; errar zera o progresso.
## Dica visual deterministica: a ordem pisca em sequencia, em ciclo. Libera o bau quando completa. Estado capturavel.

signal unlocked

const HINT_STEP: float = 1.0
const HINT_PAUSE: float = 3.0

@export var order: Array[int] = [2, 0, 3, 1]

var progress: int = 0
var is_unlocked: bool = false
var chest: Chest
var elapsed: float = 0.0
var crystals: Array[SequenceCrystal] = []


func _ready() -> void:
	add_to_group(&"snapshotable")


func press(index: int) -> void:
	if is_unlocked:
		return
	if index == order[progress]:
		progress += 1
		if progress == order.size():
			is_unlocked = true
			if chest != null:
				chest.locked = false
			unlocked.emit()
	else:
		progress = 0


## Cristal destacado pela dica no instante atual (-1 = nenhum). Ciclo: ordem inteira + pausa.
func hint_index() -> int:
	var cycle: float = HINT_STEP * order.size() + HINT_PAUSE
	var t: float = fposmod(elapsed, cycle)
	var step: int = int(t / HINT_STEP)
	return order[step] if step < order.size() else -1


func _physics_process(delta: float) -> void:
	elapsed += delta
	var h: int = hint_index()
	for c in crystals:
		c.paint(c.index == h)


func capture() -> Variant:
	return null


func restore(_state: Variant) -> void:
	progress = 0
	is_unlocked = false
	elapsed = 0.0
	if chest != null:
		chest.locked = true
