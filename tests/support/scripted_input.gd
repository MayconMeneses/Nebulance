class_name ScriptedInput
extends RefCounted
## Fonte de intencao roteirizada para testes (substitui o InputReader). Pulsos duram um quadro.

var move_axis: float = 0.0
var jump_held: bool = false
var special_held: bool = false

var _jump_pressed: bool = false
var _special_pressed: bool = false
var _swap_dir: int = 0


func press_jump() -> void:
	_jump_pressed = true
	jump_held = true


func press_special() -> void:
	_special_pressed = true
	special_held = true


func swap(dir: int) -> void:
	_swap_dir = dir


func release_all() -> void:
	move_axis = 0.0
	jump_held = false
	special_held = false


func read() -> HeroIntent:
	var intent := HeroIntent.new()
	intent.move_axis = move_axis
	intent.jump_pressed = _jump_pressed
	intent.jump_held = jump_held
	intent.special_pressed = _special_pressed
	intent.special_held = special_held
	intent.swap_dir = _swap_dir
	_jump_pressed = false
	_special_pressed = false
	_swap_dir = 0
	return intent
