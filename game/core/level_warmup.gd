class_name LevelWarmup
extends RefCounted
## Aquecimento dos VISUAIS da fase (complementa ShaderWarmup): no Compatibility cada combinacao de shader/material compila no primeiro desenho
## (picos de ~100-150 ms quando algo aparece pela primeira vez). Aqui desenhamos uma vez, atras da tela de carregamento, uma copia so visual
## (sem script, colisao ou area) de cada tipo de malha/particula da fase, deduplicada pela assinatura do material, perto do heroi e da luz dele.
## Nao altera estado de jogo: tudo e liberado ao fim do aquecimento.

const MAX_SIZE: float = 0.5
const COLUMNS: int = 8
const SPACING: float = 0.7


## Cria as copias em volta de `anchor` (filhos de `level`) e devolve as temporarias para o chamador liberar.
static func spawn(level: LevelScene, anchor: Vector3) -> Array[Node]:
	var temps: Array[Node] = []
	var seen: Dictionary = {}
	for node in level.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree() or _skip(mi, level):
			continue
		var key: String = "M|" + signature(mi.mesh.get_class(), _material_of(mi), mi.cast_shadow)
		if seen.has(key):
			continue
		seen[key] = true
		var copy := MeshInstance3D.new()
		copy.mesh = mi.mesh
		copy.material_override = mi.material_override
		copy.material_overlay = mi.material_overlay
		copy.cast_shadow = mi.cast_shadow
		_place(level, copy, anchor, temps.size(), mi.mesh.get_aabb().size)
		temps.append(copy)
		var variant: MeshInstance3D = _alpha_variant(level, copy, anchor, temps.size(), seen)
		if variant != null:
			temps.append(variant)
	for node in level.find_children("*", "CPUParticles3D", true, false):
		var src := node as CPUParticles3D
		if src.mesh == null or _skip(src, level):
			continue
		var key: String = "P|" + signature(src.mesh.get_class(), src.mesh.surface_get_material(0) if src.mesh.get_surface_count() > 0 else null, src.cast_shadow)
		if seen.has(key):
			continue
		seen[key] = true
		var copy := src.duplicate() as CPUParticles3D
		copy.one_shot = true
		_place(level, copy, anchor, temps.size(), Vector3.ONE * 0.2)
		copy.emitting = true
		temps.append(copy)
	return temps


## Poeira da corrida (particulas translucidas da aura do heroi): a aura so a emite correndo no chao, entao o 1o desenho seria em jogo.
## Usa uma COPIA solta (a aura reescreve `emitting` todo quadro de fisica).
static func dust_copy(level: LevelScene, anchor: Vector3) -> Array[Node]:
	var temps: Array[Node] = []
	for aura in level.rig.body.find_children("*", "HeroAura", true, false):
		var dust: CPUParticles3D = (aura as HeroAura).dust
		if dust == null:
			continue
		var copy := dust.duplicate() as CPUParticles3D
		copy.one_shot = true
		copy.local_coords = true
		copy.position = anchor + Vector3(0.0, 0.2, 0.6)
		level.add_child(copy)
		copy.emitting = true
		temps.append(copy)
	return temps


## Texto que identifica o que forca uma compilacao nova: shader (por caminho/instancia) ou as opcoes do StandardMaterial3D.
static func signature(mesh_class: String, mat: Material, cast_shadow: int) -> String:
	var parts: PackedStringArray = [mesh_class, str(cast_shadow)]
	if mat is ShaderMaterial:
		var shader: Shader = (mat as ShaderMaterial).shader
		parts.append("S:" + (shader.resource_path if shader != null and shader.resource_path != "" else str(shader.get_instance_id() if shader != null else 0)))
	elif mat is BaseMaterial3D:
		var b := mat as BaseMaterial3D
		parts.append("B:%d|%d|%d|%d|%d|%d|%d" % [b.transparency, b.shading_mode, int(b.emission_enabled), b.cull_mode, int(b.vertex_color_use_as_albedo), b.blend_mode, int(b.albedo_texture != null)])
	else:
		parts.append("none")
	return "|".join(parts)


## Pecas que somem/voltam (ruptura, ponte de luz) alternam o material para translucido em jogo: aquece tambem essa variante dos opacos.
static func _alpha_variant(level: LevelScene, source: MeshInstance3D, anchor: Vector3, index: int, seen: Dictionary) -> MeshInstance3D:
	var base := _material_of(source) as BaseMaterial3D
	if base == null or base.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
		return null
	var key: String = "A|" + signature(source.mesh.get_class(), base, source.cast_shadow)
	if seen.has(key):
		return null
	seen[key] = true
	var alpha := base.duplicate() as BaseMaterial3D
	alpha.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var copy := MeshInstance3D.new()
	copy.mesh = source.mesh
	copy.material_override = alpha
	copy.cast_shadow = source.cast_shadow
	_place(level, copy, anchor, index, source.mesh.get_aabb().size)
	return copy


static func _material_of(mi: MeshInstance3D) -> Material:
	if mi.material_override != null:
		return mi.material_override
	return mi.mesh.surface_get_material(0) if mi.mesh.get_surface_count() > 0 else null


## O heroi e a camera (clima, planeta no ceu) ja desenham desde o primeiro quadro: nao entram.
static func _skip(node: Node, level: LevelScene) -> bool:
	return (level.rig != null and level.rig.is_ancestor_of(node)) or (level.camera != null and level.camera.is_ancestor_of(node))


## Grade pequena na frente do heroi (dentro da vista e do alcance da sombra e da luz dele); a escala reduz peças grandes (pilares, piso).
static func _place(level: LevelScene, copy: Node3D, anchor: Vector3, index: int, size: Vector3) -> void:
	var largest: float = maxf(maxf(size.x, size.y), maxf(size.z, 0.001))
	copy.scale = Vector3.ONE * minf(1.0, MAX_SIZE / largest)
	copy.position = anchor + Vector3(float(index % COLUMNS - COLUMNS / 2) * SPACING, 0.6 + float(index / COLUMNS) * SPACING, 0.8)
	level.add_child(copy)
