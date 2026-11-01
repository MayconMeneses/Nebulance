class_name TideFlux
extends StaticBody3D
## Fluxo luminoso de Aquarys: acende quando TODOS os reservatorios estao nos niveis exigidos (combinacao discreta, sem fisica de
## fluidos). Cada exigencia tem uma lampada propria; quando `blocks` e verdadeiro, o corpo e uma porta que so abre com o fluxo aceso.
## Estado totalmente DERIVADO dos WaterBody (nada a capturar: o checkpoint restaura os reservatorios e o fluxo acompanha).

@export var door_size: Vector3 = Vector3(1.2, 3.2, 3.0)
@export var blocks: bool = true

var requirements: Array = []

var _lamps: Array[StandardMaterial3D] = []
var _door_mat: StandardMaterial3D


## Exige `water` no nivel `level`; a lampada fica em `lamp_world` (posicao do mundo).
func require_level(water: WaterBody, level: int, lamp_world: Vector3) -> void:
	requirements.append({"water": water, "level": level})
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.4, 0.3, 0.3)
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mesh.material = mat
	mi.mesh = mesh
	mi.position = lamp_world - position
	add_child(mi)
	_lamps.append(mat)


func _ready() -> void:
	collision_mask = 0
	if blocks:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = door_size
		shape.shape = box
		add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = door_size
	_door_mat = StandardMaterial3D.new()
	_door_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_door_mat.emission_enabled = true
	mesh.material = _door_mat
	mi.mesh = mesh
	mi.visible = blocks
	add_child(mi)
	_apply()


func requirement_met(index: int) -> bool:
	var r: Dictionary = requirements[index]
	return (r["water"] as WaterBody).level == int(r["level"])


func is_lit() -> bool:
	if requirements.is_empty():
		return false
	for i in requirements.size():
		if not requirement_met(i):
			return false
	return true


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	var lit: bool = is_lit()
	collision_layer = PhysicsLayers.WORLD if blocks and not lit else 0
	for i in _lamps.size():
		var on: bool = requirement_met(i)
		_lamps[i].albedo_color = Color("23CFF5") if on else Color("3A4A5A")
		_lamps[i].emission = Color("23CFF5") if on else Color.BLACK
	if _door_mat != null:
		_door_mat.albedo_color = Color(0.35, 0.95, 0.85, 0.15) if lit else Color(0.2, 0.3, 0.45, 0.85)
		_door_mat.emission = Color("23CFF5") if lit else Color.BLACK
