class_name ShapeProbe
extends RefCounted
## Consulta de sobreposicao de uma forma no mundo fisico (sem mover nada).


static func overlapping(world: World3D, shape: Shape3D, xform: Transform3D, mask: int,
		exclude: Array[RID] = [], areas: bool = true, bodies: bool = true) -> Array[Object]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = xform
	query.collision_mask = mask
	query.exclude = exclude
	query.collide_with_areas = areas
	query.collide_with_bodies = bodies
	var out: Array[Object] = []
	for hit in world.direct_space_state.intersect_shape(query, 16):
		out.append(hit["collider"])
	return out
