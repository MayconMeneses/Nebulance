class_name SpaceStage
extends SubViewportContainer
## Palco 3D TRANSPARENTE do Mapa Galactico: os seis planetas (PlanetSphere) giram sobre o fundo 2D do mapa. Camera ortografica de 720
## unidades de altura: 1 unidade = 1 pixel do mapa, entao cada planeta fica exatamente sob o ponto 2D que o mapa ja usa (botoes, raizes).
## So apresentacao: sem colisao e sem ler/gravar o save (so recebe o estado derivado para pintar os planetas).

const MAP_SIZE: Vector2 = Vector2(1280.0, 720.0)

var planets: Array[PlanetSphere] = []
var viewport: SubViewport
var camera: Camera3D


func build(defs: Array[PlanetDefinition], positions: Array[Vector2], radii: Array[float]) -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Sob um CanvasLayer nao ha retangulo-pai: o tamanho e fixo no sistema de coordenadas do mapa (1280x720).
	position = Vector2.ZERO
	size = MAP_SIZE
	viewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.size = Vector2i(MAP_SIZE)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = MAP_SIZE.y
	camera.near = 1.0
	camera.far = 600.0
	camera.position = Vector3(0.0, 0.0, 300.0)
	viewport.add_child(camera)
	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.35, 0.42, 0.6)
	env.ambient_light_energy = 0.55
	var we := WorldEnvironment.new()
	we.environment = env
	viewport.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-30.0, -40.0, 0.0)
	sun.light_energy = 1.4
	sun.light_color = Color(1.0, 0.95, 0.85)
	viewport.add_child(sun)
	for i in defs.size():
		var planet := PlanetSphere.new()
		viewport.add_child(planet)
		planet.setup(defs[i].planet_id, radii[i])
		planet.position = world_position(positions[i])
		planets.append(planet)


## Ponto 2D do mapa (pixels) -> posicao no palco (z = 0).
static func world_position(map_point: Vector2) -> Vector3:
	return Vector3(map_point.x - MAP_SIZE.x * 0.5, MAP_SIZE.y * 0.5 - map_point.y, 0.0)


func show_state(shown_save: Dictionary) -> void:
	for i in planets.size():
		planets[i].set_status(GalaxyState.status(shown_save, i))
