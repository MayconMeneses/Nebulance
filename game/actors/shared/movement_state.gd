class_name MovementState
extends RefCounted
## Estados de movimento do PDF secao 05.

enum State { IDLE, RUN, TAKEOFF, AIRBORNE, FALL, LAND, SPECIAL, INTERACT, HURT, DEAD, CUTSCENE }

const INPUT_BLOCKED: Array[int] = [State.HURT, State.DEAD, State.CUTSCENE]


static func blocks_input(state: int) -> bool:
	return state in INPUT_BLOCKED
