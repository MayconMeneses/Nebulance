extends RefCounted
## Cosmeticos: catalogo, vestir por heroi (identity.equipped_outfits), persistencia no save, brilho no modelo, espelho da fase 34 e
## garantia de que so a COR muda (atributos, habilidades e capsula intactos).

const SCARF: String = "sylvara_01_glow_scarf"
const SUIT: String = "umbraxis_s06_expedition_suit"


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_catalog(out)
	await _mirror(tree, out)
	return out


func _save_with(items: Array) -> Dictionary:
	var save: Dictionary = SaveData.new_game()
	for id in items:
		save["economy"]["owned_items"].append(id)
	return save


func _catalog(out: Array) -> void:
	var save: Dictionary = _save_with([SUIT, "mecatron_13_techgear_part", SCARF])
	TestWorld.rec(out, "cosmeticos: so itens do catalogo contam (peca comum nao veste), na ordem do catalogo",
			CosmeticCatalog.available(save) == ["sylvara_01_glow_scarf", "umbraxis_s06_expedition_suit"])
	TestWorld.rec(out, "cosmeticos: comeca no visual original; so aceita vestir o que se possui",
			CosmeticCatalog.equipped(save, &"rocco") == "" and not CosmeticCatalog.equip(save, &"rocco", "aerion_s05_legendary_cosmetic")
			and CosmeticCatalog.equip(save, &"rocco", SCARF) and CosmeticCatalog.equipped(save, &"rocco") == SCARF)
	TestWorld.rec(out, "cosmeticos: a escolha e por heroi (Zuri segue original)", CosmeticCatalog.equipped(save, &"zuri") == "")
	var seen: Array[String] = []
	for i in 3:
		var next_id: String = CosmeticCatalog.next_after(save, &"rocco")
		seen.append(next_id)
		CosmeticCatalog.equip(save, &"rocco", next_id)
	TestWorld.rec(out, "cosmeticos: o ciclo vai SCARF -> SUIT, volta ao original e recomeca", seen == [SUIT, "", SCARF], "(%s)" % [seen])
	CosmeticCatalog.equip(save, &"pipa", SUIT)
	save["economy"]["owned_items"].erase(SUIT)
	TestWorld.rec(out, "cosmeticos: item que deixa de ser possuido volta ao original", CosmeticCatalog.equipped(save, &"pipa") == "")
	var saved: Dictionary = _save_with([SCARF])
	CosmeticCatalog.equip(saved, &"zuri", SCARF)
	var round_trip: Variant = JSON.parse_string(JSON.stringify(saved))
	SaveData.normalize(round_trip)
	TestWorld.rec(out, "cosmeticos: a escolha sobrevive ao salvar e carregar (JSON) e o save segue valido",
			round_trip is Dictionary and SaveData.validate(round_trip) == "" and CosmeticCatalog.equipped(round_trip, &"zuri") == SCARF)
	var old_save: Dictionary = SaveData.new_game()
	old_save["identity"].erase("equipped_outfits")
	TestWorld.rec(out, "cosmeticos: save antigo sem o campo nao quebra (original)", CosmeticCatalog.equipped(old_save, &"rocco") == "")


func _level(tree: SceneTree, items: Array) -> UmbraxisLevel34:
	var level := UmbraxisLevel34.new()
	level.use_input_reader = false
	for id in items:
		level.save["economy"]["owned_items"].append(id)
	tree.get_root().add_child(level)
	return level


func _overlays(level: UmbraxisLevel34) -> int:
	var count: int = 0
	for n in level.visual.model.find_children("*", "GeometryInstance3D", true, false):
		if (n as GeometryInstance3D).material_overlay != null:
			count += 1
	return count


func _mirror(tree: SceneTree, out: Array) -> void:
	var level: UmbraxisLevel34 = _level(tree, [SCARF, SUIT])
	await tree.physics_frame
	await tree.physics_frame
	var mirror: CosmeticMirror = level.mirror
	TestWorld.rec(out, "fase 34: o espelho de cosmeticos e interativo (camada INTERACTABLE) e mostra o visual atual no aviso",
			mirror.can_interact() and mirror.collision_layer == PhysicsLayers.INTERACTABLE and mirror.prompt().contains("Original"))
	var profile: HeroProfile = level.rig.profiles[level.rig.active_index]
	var run_speed: float = profile.tuning.run_speed
	var jump: float = profile.tuning.jump_velocity
	var height: float = profile.capsule_height
	var before: int = _overlays(level)
	mirror.interact()
	await tree.process_frame
	var hero: StringName = level.rig.profiles[level.rig.active_index].hero_id
	TestWorld.rec(out, "fase 34: usar o espelho veste o 1o cosmetico no heroi ativo, grava no save e pinta o modelo",
			CosmeticCatalog.equipped(level.save, hero) == SCARF and level.visual.outfit_id == SCARF and before == 0 and _overlays(level) > 0,
			"(antes=%d agora=%d)" % [before, _overlays(level)])
	TestWorld.rec(out, "fase 34: o aviso do espelho passa a citar o cosmetico vestido", mirror.prompt().contains("Cachecol Luminoso"))
	TestWorld.rec(out, "cosmeticos: so a cor muda (velocidade, pulo e capsula do heroi intactos; QA 019)",
			is_equal_approx(profile.tuning.run_speed, run_speed) and is_equal_approx(profile.tuning.jump_velocity, jump)
			and is_equal_approx(profile.capsule_height, height))
	level.rig.request_swap((level.rig.active_index + 1) % level.rig.profiles.size())
	for i in 15:
		await tree.process_frame
	TestWorld.rec(out, "fase 34: trocar de heroi mostra o visual dele (original), e voltar reaplica o cosmetico do primeiro",
			level.visual.outfit_id == "" and _overlays(level) == 0)
	level.rig.request_swap((level.rig.active_index + level.rig.profiles.size() - 1) % level.rig.profiles.size())
	for i in 15:
		await tree.process_frame
	TestWorld.rec(out, "fase 34: o cosmetico do primeiro heroi volta ao reaparecer ele", level.visual.outfit_id == SCARF and _overlays(level) > 0)
	mirror.interact()
	mirror.interact()
	await tree.process_frame
	TestWorld.rec(out, "fase 34: o ciclo do espelho fecha no original e tira o brilho",
			CosmeticCatalog.equipped(level.save, hero) == "" and level.visual.outfit_id == "" and _overlays(level) == 0)
	level.queue_free()
	await tree.physics_frame
	var empty: UmbraxisLevel34 = _level(tree, [])
	await tree.physics_frame
	empty.mirror.interact()
	TestWorld.rec(out, "fase 34: sem nenhum cosmetico o espelho avisa e nao muda nada",
			empty.mirror.prompt().contains("nenhum cosmetico") and _overlays(empty) == 0)
	empty.queue_free()
	await tree.physics_frame
