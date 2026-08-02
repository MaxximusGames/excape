extends CanvasLayer

@onready var scrap_label: Label = $ScrapLabel
@onready var cash_label: Label = $CashLabel
@onready var ammo_label: Label = $AmmoLabel
@onready var weapon_info_label: Label = $WeaponInfoLabel

func _process(delta: float) -> void:
	scrap_label.text = "Scrap: " + str(GameState.banked_scrap)
	cash_label.text = "Cash: " + str(GameState.banked_cash)

	if GameState.equipped_weapon:
		var weapon = GameState.equipped_weapon
		var ammo = GameState.get_ammo_state(weapon)
		ammo_label.text = weapon.weapon_name + " Munition: " + str(ammo.reserve)

		var info_text = "Aktuelle Waffe: " + weapon.weapon_name + "\n\n"
		info_text += "Attachments:\n"
		info_text += "Lauf: " + (weapon.equipped_barrel.attachment_name if weapon.equipped_barrel else "-") + "\n"
		info_text += "Verschluss: " + (weapon.equipped_bolt.attachment_name if weapon.equipped_bolt else "-") + "\n"
		info_text += "Körper: " + (weapon.equipped_body.attachment_name if weapon.equipped_body else "-") + "\n\n"
		info_text += "Werte:\n"
		info_text += "Schaden: " + "%.1f" % weapon.get_effective_damage() + "\n"
		info_text += "Feuerrate: " + "%.2f" % weapon.get_effective_fire_rate() + "s\n"
		info_text += "Geschossgeschw.: " + "%.0f" % weapon.get_effective_bullet_speed() + "\n"
		info_text += "Streuung: " + "%.1f" % weapon.get_effective_spread() + "°\n"
		info_text += "Lautstärke: " + "%.0f" % weapon.get_effective_volume() + "\n"
		info_text += "Reichweite: " + "%.0f" % weapon.get_effective_range() + "\n"
		info_text += "Gewicht: " + "%.2f" % weapon.get_effective_weight()

		weapon_info_label.text = info_text
