class_name LightBridge
extends StaticBody3D
## Plataforma/portao movido pela luz: solida enquanto o alvo `link_id` esta aceso (ponte) ou ao contrario (`opens_when_lit`: portao).
## O estado e derivado do BeamField a cada quadro (nada guardado a parte; o checkpoint restaura os prismas).

@export var link_id: StringName = &""
@export var size: Vector3 = Vector3(6.0, 0.4, 3.0)
@export var opens_when_lit: bool = false

var field: BeamField

var _material: StandardMaterial3D


func _ready() -> void:
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	_apply()


func is_solid() -> bool:
	var lit: bool = field != null and field.is_lit(link_id)
	return not lit if opens_when_lit else lit


func _physics_process(_delta: float) -> void:
	_apply()


func _apply() -> void:
	var solid: bool = is_solid()
	collision_layer = PhysicsLayers.WORLD if solid else 0
	var c: Color = Color("A78BFA") if solid else Color(0.4, 0.3, 0.6, 0.2)
	_material.albedo_color = c
	_material.emission = c if solid else Color.BLACK
	_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED if solid else BaseMaterial3D.TRANSPARENCY_ALPHA
