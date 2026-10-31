class_name TriadFinisher
extends Node3D
## Golpe Triade: tres pontos de interacao que exigem tres HEROIS DIFERENTES (qualquer ordem). So liberado na fase FINISH.
## O mesmo heroi nao consegue ativar dois pontos. Estado capturavel (checkpoint).

signal completed

var boss: VyrkanBoss
var rig: TrioRig
var nodes: Array[TriadNode] = []
var used_heroes: Array[StringName] = []


## Chamado na GEOMETRIA (antes do setup do controller) para entrar no snapshot do checkpoint.
func build(positions: Array[Vector3]) -> void:
	add_to_group(&"snapshotable")
	for i in positions.size():
		var n := TriadNode.new()
		n.finisher = self
		n.index = i
		n.position = positions[i]
		add_child(n)
		nodes.append(n)


func link(p_boss: VyrkanBoss, p_rig: TrioRig) -> void:
	boss = p_boss
	rig = p_rig


func can_press(node: TriadNode) -> bool:
	return boss != null and boss.phase == VyrkanBoss.Phase.FINISH and not node.is_active and not rig.body.profile.hero_id in used_heroes


func press(node: TriadNode) -> void:
	if not can_press(node):
		return
	used_heroes.append(rig.body.profile.hero_id)
	node.set_active(true)
	if used_heroes.size() == nodes.size():
		boss.finish_triad()
		completed.emit()


func capture() -> Variant:
	return null


func restore(_state: Variant) -> void:
	used_heroes.clear()
	for n in nodes:
		n.set_active(false)
