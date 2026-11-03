class_name CosmeticMirror
extends Area3D
## Espelho de cosmeticos (interativo): cada E troca o visual do heroi ATIVO entre o original e os cosmeticos que o jogador possui.
## So muda a cor do modelo (ver CosmeticCatalog); nao altera atributos. O dicionario do save e o do jogo (mesma referencia).

signal outfit_changed(hero_id: StringName, outfit_id: String)

var save: Dictionary = {}
var rig: TrioRig
var visual: HeroVisual


func _ready() -> void:
	collision_layer = PhysicsLayers.INTERACTABLE
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.6, 2.2, 1.6)
	shape.shape = box
	add_child(shape)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.2, 2.0, 0.15)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("23CFF5")
	mat.emission_enabled = true
	mat.emission = Color("23CFF5")
	mesh.material = mat
	mi.mesh = mesh
	add_child(mi)


func bind(game_save: Dictionary, trio: TrioRig, hero_visual: HeroVisual) -> void:
	save = game_save
	rig = trio
	visual = hero_visual


func can_interact() -> bool:
	return rig != null


func prompt() -> String:
	if rig == null:
		return ""
	if CosmeticCatalog.available(save).is_empty():
		return "Espelho: nenhum cosmetico ainda (visual: Original)"
	return "Pressione E para trocar o visual (agora: %s)" % CosmeticCatalog.display_name(CosmeticCatalog.equipped(save, _hero()))


func interact() -> void:
	if rig == null:
		return
	var hero: StringName = _hero()
	var next_id: String = CosmeticCatalog.next_after(save, hero)
	CosmeticCatalog.equip(save, hero, next_id)
	if visual != null:
		visual.refresh_outfit()
	outfit_changed.emit(hero, next_id)


func _hero() -> StringName:
	return rig.profiles[rig.active_index].hero_id
