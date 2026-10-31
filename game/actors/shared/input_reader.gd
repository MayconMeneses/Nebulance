class_name InputReader
extends Node
## Unica ponte entre o InputMap e o HeroIntent.


func read() -> HeroIntent:
	var intent := HeroIntent.new()
	intent.move_axis = Input.get_axis(&"move_left", &"move_right")
	intent.jump_pressed = Input.is_action_just_pressed(&"jump")
	intent.jump_held = Input.is_action_pressed(&"jump")
	intent.special_pressed = Input.is_action_just_pressed(&"special")
	intent.special_held = Input.is_action_pressed(&"special")
	intent.interact_pressed = Input.is_action_just_pressed(&"interact")
	intent.swap_dir = int(Input.is_action_just_pressed(&"swap_next")) - int(Input.is_action_just_pressed(&"swap_prev"))
	return intent
