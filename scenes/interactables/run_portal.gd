extends Area2D

@export var hold_time: float = 1.5

var player_in_range: Node2D = null
var progress: float = 0.0

@onready var prompt_label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.text = "Halte [E] um Run zu starten"
	prompt_label.visible = false
	progress_bar.visible = false

func _process(delta: float) -> void:
	if player_in_range:
		prompt_label.visible = true
		if Input.is_action_pressed("interact"):
			progress_bar.visible = true
			progress += delta
			progress_bar.value = (progress / hold_time) * 100
			if progress >= hold_time:
				start_run()
		else:
			progress = 0.0
			progress_bar.visible = false
	else:
		prompt_label.visible = false
		progress_bar.visible = false

func start_run() -> void:
	GameState.reset_run_stats()
	GameState.reset_health()
	get_tree().change_scene_to_file("res://scenes/levels/level_01.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
