class_name ScreenVignette
extends CanvasLayer
## Vinheta suave nas bordas da tela (textura radial pre-calculada: sem ler a tela, custo minimo). Fica ABAIXO do HUD. So aparencia.

const STRENGTH: float = 0.5


func _ready() -> void:
	layer = 0
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color(0.0, 0.0, 0.05, 0.0), Color(0.0, 0.0, 0.05, 0.0), Color(0.0, 0.0, 0.05, STRENGTH)])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 1.0)
	tex.width = 256
	tex.height = 256
	var rect := TextureRect.new()
	rect.texture = tex
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.size = Vector2(1280.0, 720.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
