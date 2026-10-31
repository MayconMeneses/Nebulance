class_name PlaceholderVisual
extends Node3D
## Visual PROVISORIO dos herois (capsula colorida pela paleta do PDF). Sera trocado pelos modelos 3D.

const COLORS: Dictionary = {
	&"rocco": Color("1C416B"),
	&"zuri": Color("52368A"),
	&"pipa": Color("F2EDE2"),
}

var _mesh: MeshInstance3D
var _material: StandardMaterial3D


func _init() -> void:
	_mesh = MeshInstance3D.new()
	_mesh.mesh = CapsuleMesh.new()
	_material = StandardMaterial3D.new()
	_mesh.material_override = _material
	add_child(_mesh)


func show_hero(profile: HeroProfile) -> void:
	var capsule := _mesh.mesh as CapsuleMesh
	capsule.radius = profile.capsule_radius
	capsule.height = profile.capsule_height
	_material.albedo_color = COLORS.get(profile.hero_id, Color.WHITE)
