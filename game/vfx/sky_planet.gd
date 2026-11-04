class_name SkyPlanet
extends Node3D
## O planeta da fase, gigante e girando no ceu (reusa o PlanetSphere do mapa): corrompido ou restaurado conforme a semente no save.
## Fica preso a camera (como um corpo muito distante: sem paralaxe). So aparencia.

const OFFSET: Vector3 = Vector3(46.0, 26.0, -150.0)
const RADIUS: float = 26.0

var planet: PlanetSphere


func setup(planet_id: StringName, restored: bool) -> void:
	planet = PlanetSphere.new()
	add_child(planet)
	planet.setup(planet_id, RADIUS)
	planet.set_status(3 if restored else 2)
	position = OFFSET
