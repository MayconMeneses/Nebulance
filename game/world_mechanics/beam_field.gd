class_name BeamField
extends Node3D
## Campo de feixes de uma fase: emissores, prismas girateis (E), alvos (cristais) e blocos. Recalcula quando algo muda.
## Estado dos alvos e DERIVADO dos prismas (nada guardado a parte); os prismas sao capturaveis pelo checkpoint.

signal changed

@export var origin: Vector3 = Vector3.ZERO
@export var bounds: Rect2i = Rect2i(-2, 0, 80, 14)

var emitters: Array = []            # [{"cell": Vector2i, "dir": Vector2i}]
var prisms: Array[BeamPrism] = []
var blockers: Dictionary = {}
var targets: Dictionary = {}        # Vector2i -> link_id (StringName)
var lit_links: Dictionary = {}
var dirty: bool = true

var _beams: Array[MeshInstance3D] = []


func cell_to_world(cell: Vector2i) -> Vector3:
	return origin + Vector3(cell.x, cell.y, 0.0)


func add_emitter(cell: Vector2i, dir: Vector2i) -> void:
	emitters.append({"cell": cell, "dir": dir})
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.6, 0.6, 0.6)
	mesh.material = _glow(Color("FFE14A"))
	mi.mesh = mesh
	mi.position = cell_to_world(cell)
	add_child(mi)


func add_prism(cell: Vector2i, orientation: int) -> BeamPrism:
	var p := BeamPrism.new()
	p.cell = cell
	p.orientation = orientation
	p.field = self
	p.position = cell_to_world(cell)
	add_child(p)
	prisms.append(p)
	return p


func add_target(cell: Vector2i, link_id: StringName) -> void:
	targets[cell] = link_id
	var mi := MeshInstance3D.new()
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.7, 0.9, 0.7)
	mesh.material = _glow(Color("A78BFA"))
	mi.mesh = mesh
	mi.position = cell_to_world(cell)
	add_child(mi)


func add_blocker(cell: Vector2i) -> void:
	blockers[cell] = true


func is_lit(link_id: StringName) -> bool:
	return lit_links.has(link_id)


func mark_dirty() -> void:
	dirty = true


func _physics_process(_delta: float) -> void:
	if dirty:
		dirty = false
		recompute()


func recompute() -> void:
	var prism_map: Dictionary = {}
	for p in prisms:
		prism_map[p.cell] = p.orientation
	var lit: Dictionary = {}
	var all_segments: Array = []
	for e in emitters:
		var result: Dictionary = BeamSolver.trace(e["cell"], e["dir"], prism_map, blockers, targets, bounds)
		all_segments.append_array(result["segments"])
		for id in result["hits"]:
			lit[id] = true
	lit_links = lit
	_draw(all_segments)
	changed.emit()


func _draw(segments: Array) -> void:
	for b in _beams:
		b.queue_free()
	_beams.clear()
	for s in segments:
		var a: Vector3 = cell_to_world(s[0])
		var b: Vector3 = cell_to_world(s[1])
		if a.is_equal_approx(b):
			continue
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(maxf(absf(b.x - a.x), 0.12), maxf(absf(b.y - a.y), 0.12), 0.12)
		mesh.material = _glow(Color("FFE14A"))
		mi.mesh = mesh
		mi.position = (a + b) * 0.5
		add_child(mi)
		_beams.append(mi)


func _glow(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	return mat
