class_name GearDecor
extends Node3D
## Engrenagem decorativa de fundo, sem colisao. Gira com sentido e velocidade fixos (deterministico e legivel);
## parada com "Reduzir movimento".

@export var radius: float = 1.5
@export var spin_speed: float = 0.8
@export var teeth: int = 8


func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("8A5A2B")
	mat.emission_enabled = true
	mat.emission = Color("3A2410")
	var disc := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.4
	cyl.material = mat
	disc.mesh = cyl
	disc.rotation_degrees.x = 90.0
	add_child(disc)
	for i in teeth:
		var tooth := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(radius * 0.35, radius * 0.35, 0.4)
		box.material = mat
		tooth.mesh = box
		var a: float = TAU * i / teeth
		tooth.position = Vector3(cos(a), sin(a), 0.0) * radius
		tooth.rotation.z = a
		add_child(tooth)


func _process(delta: float) -> void:
	if not Accessibility.reduce_motion:
		rotation.z += spin_speed * delta
