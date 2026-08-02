extends CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		GameState.reset_health()
		get_tree().change_scene_to_file("res://scenes/levels/homebase.tscn")
