extends CanvasLayer

@onready var scrap_label: Label = $ScrapLabel
@onready var cash_label: Label = $CashLabel
@onready var ammo_label: Label = $AmmoLabel


func _process(delta: float) -> void:
	scrap_label.text = "Scrap: " + str(GameState.banked_scrap)
	cash_label.text = "Cash: " + str(GameState.banked_cash)

	if GameState.equipped_weapon:
		var weapon = GameState.equipped_weapon
		var ammo = GameState.get_ammo_state(weapon)
		ammo_label.text = weapon.weapon_name + " Munition: " + str(ammo.reserve)
