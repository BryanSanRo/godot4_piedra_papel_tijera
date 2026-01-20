extends Node

@onready var player: AudioStreamPlayer = $Player
var volume_linear: float = 0.6 

func _ready() -> void:
	_apply_volume()

func set_volume_linear(v: float) -> void:
	volume_linear = clampf(v, 0.0, 1.0)
	_apply_volume()

func get_volume_linear() -> float:
	return volume_linear

func _apply_volume() -> void:
	var v: float = maxf(volume_linear, 0.001) 
	player.volume_db = linear_to_db(v)
