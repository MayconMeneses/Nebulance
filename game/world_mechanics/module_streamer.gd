class_name ModuleStreamer
extends Node
## Carrega e DESCARREGA de verdade os modulos de uma fase (fase 32: "checkpoints entre modulos sem manter todos os mundos na memoria").
## Cada modulo vive num no proprio (`Module<i>`) montado pela funcao de construcao registrada; descarregar = tirar o no da arvore e
## libera-lo (colisao, mecanismos e malhas somem). Os nomes dos nos sao estaveis, entao o snapshot do checkpoint (chaves por caminho)
## continua valido quando um modulo e recriado. Quem decide QUAIS modulos ficam e a fase (plano por checkpoint); aqui so se carrega/descarrega.

signal module_loaded(index: int)
signal module_freed(index: int)

var world: Node3D
var builder: SegmentBuilder

var _builders: Array[Callable] = []
var _origins: Array[float] = []
var _loaded: Dictionary = {}


## `build` recebe (container: Node3D, builder: SegmentBuilder, ox: float) e devolve o dicionario de nos do modulo.
func add_module(ox: float, build: Callable) -> int:
	_builders.append(build)
	_origins.append(ox)
	return _builders.size() - 1


func module_count() -> int:
	return _builders.size()


func is_loaded(index: int) -> bool:
	return _loaded.has(index)


func loaded_indices() -> Array:
	var keys: Array = _loaded.keys()
	keys.sort()
	return keys


func container(index: int) -> Node3D:
	return _loaded.get(index)


## Deixa carregados EXATAMENTE os modulos pedidos: cria os que faltam (em ordem) e libera os demais.
func set_loaded(indices: Array) -> void:
	for index in loaded_indices():
		if not index in indices:
			_free_module(index)
	for index in indices:
		if not _loaded.has(index) and index >= 0 and index < _builders.size():
			_load_module(index)


func _load_module(index: int) -> void:
	var holder := Node3D.new()
	holder.name = "Module%d" % index
	world.add_child(holder)
	var previous_parent: Node3D = builder.parent
	builder.parent = holder
	(_builders[index] as Callable).call(holder, builder, _origins[index])
	builder.parent = previous_parent
	_loaded[index] = holder
	module_loaded.emit(index)


func _free_module(index: int) -> void:
	var holder: Node3D = _loaded[index]
	_loaded.erase(index)
	holder.get_parent().remove_child(holder)
	holder.queue_free()
	module_freed.emit(index)
