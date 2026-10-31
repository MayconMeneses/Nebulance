class_name HeroSwapper
extends RefCounted
## Validacao e execucao atomica da troca de heroi (PDF secao 05).

enum Result { OK, SAME_HERO, DENIED_STATE, DENIED_SPACE }

const FEET_EPSILON: float = 0.02
## Regra de troca no ar (ADR-0005): permitida, exceto durante habilidade ativa (SPECIAL) ou HURT/DEAD/CUTSCENE.
const DENIED_STATES: Array[int] = [MovementState.State.SPECIAL, MovementState.State.HURT,
		MovementState.State.DEAD, MovementState.State.CUTSCENE]


func validate(body: ActorController, target: HeroProfile) -> Result:
	if target == body.profile:
		return Result.SAME_HERO
	if body.state in DENIED_STATES:
		return Result.DENIED_STATE
	return Result.OK if _fits(body, target) else Result.DENIED_SPACE


## Troca somente se valido; preserva posicao dos pes, velocidade e (por estar no TrioVitals) vidas/coracoes.
func swap(body: ActorController, target: HeroProfile) -> Result:
	var result: Result = validate(body, target)
	if result == Result.OK:
		body.apply_profile(target, true)
	return result


func _fits(body: ActorController, target: HeroProfile) -> bool:
	var current := body.collision_shape.shape as CapsuleShape3D
	var candidate := CapsuleShape3D.new()
	candidate.radius = target.capsule_radius
	candidate.height = target.capsule_height
	var feet_y: float = body.global_position.y - current.height * 0.5
	var xform: Transform3D = body.collision_shape.global_transform
	xform.origin.y = feet_y + target.capsule_height * 0.5 + FEET_EPSILON
	var hits: Array[Object] = ShapeProbe.overlapping(body.get_world_3d(), candidate, xform,
			PhysicsLayers.WORLD, [body.get_rid()] as Array[RID], false, true)
	return hits.is_empty()
