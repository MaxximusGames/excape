extends Area2D

@export var item_name: String = "Scrap"
@export var value: int = 10
@export var loot_time: float = 2.0

var player_in_range: Node2D = null
var loot_progress: float = 0.0

@onready var prompt_label: Label = $PromptLabel
@onready var progress_bar: ProgressBar = $LootProgressBar

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.text = "Halte [E] zum Looten"
	prompt_label.visible = false
	progress_bar.visible = false
	progress_bar.value = 0

func _process(delta: float) -> void:
	if player_in_range:
		prompt_label.visible = true
		if Input.is_action_pressed("interact"):
			progress_bar.visible = true
			loot_progress += delta
			progress_bar.value = (loot_progress / loot_time) * 100
			if loot_progress >= loot_time:
				player_in_range.collect_item(item_name, value)
				queue_free()
		else:
			loot_progress = 0.0
			progress_bar.visible = false
			progress_bar.value = 0
	else:
		prompt_label.visible = false
		progress_bar.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
