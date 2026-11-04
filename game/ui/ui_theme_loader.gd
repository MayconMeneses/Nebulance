extends Node
## Autoload UiTheme: aplica o tema futurista (FuturisticTheme) a todas as telas pelo Window raiz.


func _ready() -> void:
	get_window().theme = FuturisticTheme.build()
