extends Node2D

var run_start_time: float = 0.0

func _ready() -> void:
	run_start_time = Time.get_ticks_msec() / 1000.0
