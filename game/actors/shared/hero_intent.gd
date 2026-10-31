class_name HeroIntent
extends RefCounted
## Intencao do jogador num quadro de fisica. O controller nunca le o Input diretamente.

var move_axis: float = 0.0
var jump_pressed: bool = false
var jump_held: bool = false
var special_pressed: bool = false
var special_held: bool = false
## -1 = heroi anterior, +1 = proximo, 0 = nenhum (pulso de um quadro).
var swap_dir: int = 0
