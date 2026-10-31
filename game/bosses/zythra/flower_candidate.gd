class_name FlowerCandidate
extends Area3D
## Uma das tres flores da fase 2 de Zythra. A REAL e estavel; as ilusoes PISCAM (evidencia visual). Errar tira um coracao e reinicia o ciclo.

var boss: ZythraBoss
var vitals: TrioVitals
var is_real: bool = false
var enabled: bool = false
var elapsed: float = 0.0

var _material: StandardMaterial3D


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 1.8, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	_material = StandardMaterial3D.new()
	_material.emission_enabled = true
	mesh.material = _material
	mi.mesh = mesh
	add_child(mi)
	_paint()


## Evidencia: a real nunca pisca. As ilusoes alternam a cada 0,3 s.
func steady() -> bool:
	return is_real or int(elapsed / 0.3) % 2 == 0


func can_interact() -> bool:
	return enabled and boss != null and boss.phase == VyrkanBoss.Phase.TWO


func prompt() -> String:
	return "Pressione E para tocar a flor"


func interact() -> void:
	if is_real:
		boss.mechanism_done(&"real")
	else:
		boss.wrong_flower()
		if vitals != null:
			vitals.hit()


func _physics_process(delta: float) -> void:
	elapsed += delta
	enabled = boss != null and boss.phase == VyrkanBoss.Phase.TWO
	visible = enabled
	_paint()


func _paint() -> void:
	if _material != null:
		var c: Color = Color("C084FC") if steady() else Color("56DDB5")
		_material.albedo_color = c
		_material.emission = c
