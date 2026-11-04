class_name DimensionalShortcut
extends Area3D
## Atalho dimensional (segredo da fase 32): uma fenda que, ao interagir (E), leva o heroi adiante. Quem decide o que carregar e para onde ir
## e a fase (liga `used`); aqui so ha a interacao e o visual. Sem estado proprio: nao e capturado pelo checkpoint.

signal used(shortcut: DimensionalShortcut)

func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 2.4, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.55
	mesh.outer_radius = 0.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("C03CA8")
	mat.emission_enabled = true
	mat.emission = Color("C03CA8")
	mat.emission_energy_multiplier = 1.6
	mesh.material = mat
	mi.mesh = mesh
	mi.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	add_child(mi)


func can_interact() -> bool:
	return true


func prompt() -> String:
	return "Pressione E para atravessar a fenda dimensional"


func interact() -> void:
	used.emit(self)
