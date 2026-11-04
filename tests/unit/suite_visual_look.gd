extends RefCounted
## Visual futurista (TC-066): paleta por planeta e por estado (corrompido x restaurado), blocos com shader de painel sem mexer na colisao,
## ceu/nevoa/brilho por fase, brilho ligado ao perfil grafico e fundo de profundidade sem colisao. LIMITE: o modo sem janela NAO compila
## shaders; a compilacao e a aparencia foram conferidas a parte, renderizando fases numa janela real (screenshots do desenvolvimento).


func run(tree: SceneTree) -> Array:
	var out: Array = []
	_palette(out)
	_shader(out)
	_blocks(tree, out)
	await _level(tree, out)
	_backdrop(tree, out)
	_graphics(tree, out)
	return out


func _palette(out: Array) -> void:
	var tints_ok: bool = true
	for planet in GalaxyState.planets():
		var c: Color = PlanetPalette.tint_of(planet.planet_id)
		tints_ok = tints_ok and absf(c.r - planet.tint.r) < 0.01 and absf(c.g - planet.tint.g) < 0.01 and absf(c.b - planet.tint.b) < 0.01
	TestWorld.rec(out, "TC-066 visual: a cor de cada planeta na paleta confere com o recurso do planeta", tints_ok)
	var differ: bool = true
	for planet in GalaxyState.planets():
		var bad: Dictionary = PlanetPalette.of(planet.planet_id, false)
		var good: Dictionary = PlanetPalette.of(planet.planet_id, true)
		differ = differ and bad["sky_horizon"] != good["sky_horizon"] and bad["fog_density"] > good["fog_density"] \
				and (good["ambient"] as Color).get_luminance() > (bad["ambient"] as Color).get_luminance()
	TestWorld.rec(out, "TC-066 visual: restaurado e corrompido sao diferentes (ceu, mais nevoa e menos luz no corrompido) nos seis planetas", differ)
	var linked: bool = true
	for seeds in 7:
		var save: Dictionary = GalaxyState.qa_save(seeds)
		for i in 6:
			var planet: PlanetDefinition = GalaxyState.planets()[i]
			linked = linked and PlanetPalette.restored(save, planet.planet_id) == GalaxyState.seed_destroyed(save, planet)
	TestWorld.rec(out, "TC-066 visual: planeta restaurado = semente destruida no save (mesma regra do mapa)", linked)


func _shader(out: Array) -> void:
	var shader: Shader = load(FuturisticLook.SHADER_PATH) as Shader
	var names: Array[String] = []
	for u in shader.get_shader_uniform_list():
		names.append(u["name"])
	TestWorld.rec(out, "TC-066 visual: o shader de painel e espacial e expoe cor, friso, tamanho e chanfro",
			shader.get_mode() == Shader.MODE_SPATIAL and "base_color" in names and "trim_color" in names and "half_size" in names and "bevel" in names)


func _blocks(tree: SceneTree, out: Array) -> void:
	var holder := Node3D.new()
	tree.get_root().add_child(holder)
	var b := SegmentBuilder.new(holder)
	var body: StaticBody3D = b.solid(Vector3(10.0, 0.0, 0.0), Vector3(4.0, 0.5, 3.0), Color("3E7A63"))
	var cs: CollisionShape3D = body.get_child(0) as CollisionShape3D
	var mesh: MeshInstance3D = body.get_child(1) as MeshInstance3D
	var mat := mesh.mesh.material as ShaderMaterial
	TestWorld.rec(out, "TC-066 visual: o bloco solido usa o material de painel com o tamanho do bloco",
			mat != null and (mat.get_shader_parameter("half_size") as Vector3).is_equal_approx(Vector3(2.0, 0.25, 1.5)))
	TestWorld.rec(out, "TC-066 visual: a colisao do bloco nao mudou (mesma caixa, camada de mundo)",
			(cs.shape as BoxShape3D).size == Vector3(4.0, 0.5, 3.0) and body.collision_layer == PhysicsLayers.WORLD and (mesh.mesh as BoxMesh).size == Vector3(4.0, 0.5, 3.0))
	TestWorld.rec(out, "TC-066 visual: o construtor guarda a extensao em x das pecas solidas (para o fundo)", is_equal_approx(b.min_x, 8.0) and is_equal_approx(b.max_x, 12.0))
	var zone: LevelZone = b.zone(PhysicsLayers.CHECKPOINT, "z", Vector3.ZERO, Vector3(1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.3))
	TestWorld.rec(out, "TC-066 visual: as zonas translucidas continuam com material padrao", (zone.get_child(zone.get_child_count() - 1) as MeshInstance3D).mesh.material is StandardMaterial3D)
	holder.queue_free()


func _level(tree: SceneTree, out: Array) -> void:
	var results: Array = []
	for restored in [false, true]:
		var level := SylvaraLevel01.new()
		level.use_input_reader = false
		if restored:
			level.save["world"]["seed_destroyed_ids"].append("seed_sylvara")
		tree.get_root().add_child(level)
		await tree.process_frame
		var env: Environment = null
		for n in level.get_children():
			if n is WorldEnvironment:
				env = (n as WorldEnvironment).environment
		var colliders: int = 0
		for n in level.find_children("*", "CollisionObject3D", true, false):
			colliders += 1
		results.append([env, colliders, level.palette.get("fog_density", 0.0), level.get_children().filter(func(n: Node) -> bool: return n is FuturisticBackdrop).size()])
		level.queue_free()
		await tree.process_frame
	var env_a: Environment = results[0][0]
	var env_b: Environment = results[1][0]
	TestWorld.rec(out, "TC-066 visual: a fase tem ceu procedural, nevoa e tonemap proprios",
			env_a != null and env_a.background_mode == Environment.BG_SKY and env_a.sky != null and env_a.fog_enabled and env_a.tonemap_mode == Environment.TONE_MAPPER_FILMIC)
	TestWorld.rec(out, "TC-066 visual: a mesma fase restaurada tem menos nevoa que a corrompida", env_a != null and env_b != null and env_a.fog_density > env_b.fog_density)
	TestWorld.rec(out, "TC-066 visual: restaurar nao muda a fisica (mesmo numero de corpos de colisao) e o fundo existe uma vez", results[0][1] == results[1][1] and results[0][3] == 1 and results[1][3] == 1)


func _backdrop(tree: SceneTree, out: Array) -> void:
	var counts: Array[int] = []
	var first: Array[Vector3] = []
	for i in 2:
		var bd := FuturisticBackdrop.new()
		tree.get_root().add_child(bd)
		bd.build(0.0, 200.0, PlanetPalette.of(&"aerion", false), "aerion_28")
		counts.append(bd.get_child_count())
		first.append((bd.get_child(0) as Node3D).position)
		if i == 0:
			TestWorld.rec(out, "TC-066 visual: o fundo nao tem nenhum corpo de colisao e fica enxuto (< 60 nos)",
					bd.find_children("*", "CollisionObject3D", true, false).is_empty() and bd.get_child_count() < 60)
		bd.queue_free()
	TestWorld.rec(out, "TC-066 visual: o fundo e deterministico (mesma semente, mesmas posicoes)", counts[0] == counts[1] and first[0] == first[1])


func _graphics(tree: SceneTree, out: Array) -> void:
	var low: Dictionary = GraphicsProfile.values("low")
	var high: Dictionary = GraphicsProfile.values("high")
	TestWorld.rec(out, "TC-066 visual: so o perfil Alto liga o brilho (glow, ~3,5 ms medidos no Intel UHD 620); Baixo e Medio ficam sem ele", not low["glow"] and high["glow"] and not GraphicsProfile.values("medium")["glow"])
	var we := WorldEnvironment.new()
	we.environment = LevelAtmosphere.environment(PlanetPalette.of(&"sylvara", false))
	we.add_to_group(LevelAtmosphere.GROUP)
	tree.get_root().add_child(we)
	var settings: Dictionary = SettingsStore.defaults()
	settings["graphics_profile"] = "low"
	GraphicsApplier.apply(tree.get_root(), settings, tree)
	var off: bool = not we.environment.glow_enabled and not GraphicsProfile.glow_on
	settings["graphics_profile"] = "high"
	GraphicsApplier.apply(tree.get_root(), settings, tree)
	TestWorld.rec(out, "TC-066 visual: trocar o perfil grafico liga/desliga o brilho da fase em andamento", off and we.environment.glow_enabled and GraphicsProfile.glow_on)
	settings["graphics_profile"] = "medium"
	GraphicsApplier.apply(tree.get_root(), settings, tree)
	we.queue_free()
