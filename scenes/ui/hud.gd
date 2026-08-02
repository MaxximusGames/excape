extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var cash_label: Label = $CashLabel
@onready var timer_label: Label = $TimerLabel

func _process(delta: float) -> void:
	health_bar.max_value = GameState.max_player_health
	health_bar.value = GameState.player_health
	health_label.text = str(int(GameState.player_health)) + " / " + str(int(GameState.max_player_health))

	scrap_label.text = "Scrap: " + str(GameState.run_scrap) + " (" + str(GameState.banked_scrap) + ")"
	cash_label.text = "Cash: " + str(GameState.banked_cash)

	var level_node = get_tree().current_scene
	if level_node.has_method("get") and "run_start_time" in level_node:
		var elapsed = (Time.get_ticks_msec() / 1000.0) - level_node.run_start_time
		timer_label.text = "Zeit: " + str(int(elapsed)) + "s"
