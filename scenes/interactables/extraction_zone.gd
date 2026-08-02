extends Area2D

@export var extraction_time: float = 5.0

var player_inside: Node2D = null
var timer: float = 0.0
var extracted: bool = false

@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	label.visible = false

func _process(delta: float) -> void:
	if extracted:
		return

	if player_inside:
		timer += delta
		label.visible = true
		var remaining = extraction_time - timer
		label.text = "Extraktion: %.1f" % remaining
		if timer >= extraction_time:
			extract()
	else:
		timer = 0.0
		label.visible = false

func extract() -> void:
	extracted = true
	label.text = "Extrahiert!"

	var level_node = get_tree().current_scene
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - level_node.run_start_time
	var time_bonus = int(elapsed_time)

	GameState.on_run_success(time_bonus)
	get_tree().change_scene_to_file("res://scenes/levels/extraction_success.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null
