extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var scrap_label: Label = $ScrapLabel
@onready var cash_label: Label = $CashLabel
@onready var timer_label: Label = $TimerLabel
@onready var ammo_label: Label = $AmmoLabel
@onready var reserve_ammo_label: Label = $ReserveAmmoLabel


func _process(delta: float) -> void:
	health_bar.max_value = GameState.max_player_health
	health_bar.value = GameState.player_health
	health_label.text = "HP: " + str(int(GameState.player_health)) + " / " + str(int(GameState.max_player_health))

	scrap_label.text = "Scrap: " + str(GameState.run_scrap) + " (" + str(GameState.banked_scrap) + ")"
	cash_label.text = "Cash: " + str(GameState.banked_cash)

	var level_node = get_tree().current_scene
	if level_node.has_method("get") and "run_start_time" in level_node:
		var elapsed = (Time.get_ticks_msec() / 1000.0) - level_node.run_start_time
		timer_label.text = "Zeit: " + str(int(elapsed)) + "s"
		
	if GameState.equipped_weapon:
		var weapon = GameState.equipped_weapon
		var ammo = GameState.get_ammo_state(weapon)
		ammo_label.text = str(ammo.in_mag) + " / " + str(weapon.magazine_size)
		reserve_ammo_label.text = str(ammo.reserve)
