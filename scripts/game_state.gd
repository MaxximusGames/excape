extends Node
signal noise_made(position: Vector2, volume: float)

var banked_scrap: int = 1500
var banked_cash: int = 2500

var run_scrap: int = 0
var run_loot: Array = []
var run_kills: int = 0
var run_damage_dealt: float = 0.0
var ammo_state: Dictionary = {}

var player_health: float = 100.0
var max_player_health: float = 100.0

var owned_attachments: Array[WeaponAttachment] = []
var owned_weapons: Array[WeaponData] = []
var equipped_weapon: WeaponData = null
var ui_open: bool = false

var last_run_summary: Dictionary = {}

func load_all_weapons() -> Array[WeaponData]:
	var result: Array[WeaponData] = []
	var dir = DirAccess.open("res://resources/weapons/")
	if not dir:
		push_error("Waffen-Ordner nicht gefunden")
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource = load("res://resources/weapons/" + file_name)
			if resource is WeaponData:
				result.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()

	return result

func _ready() -> void:
	var all_weapons = load_all_weapons()
	for weapon in all_weapons:
		if weapon.free_starting_ammo:
			owned_weapons.append(weapon)
			equipped_weapon = weapon
			break

func add_item(item_name: String, value: int) -> void:
	run_loot.append({"name": item_name, "value": value})
	run_scrap += value

func reset_run_stats() -> void:
	run_scrap = 0
	run_loot.clear()
	run_kills = 0
	run_damage_dealt = 0.0

func on_run_failed() -> void:
	reset_run_stats()

func get_ammo_state(weapon: WeaponData) -> Dictionary:
	if not ammo_state.has(weapon):
		ammo_state[weapon] = {"in_mag": weapon.magazine_size, "reserve": weapon.starting_reserve_ammo}
	return ammo_state[weapon]

func reload_weapon(weapon: WeaponData) -> void:
	var state = get_ammo_state(weapon)
	var needed = weapon.magazine_size - state.in_mag
	var available = min(needed, state.reserve)
	state.in_mag += available
	state.reserve -= available
	
func refill_starter_weapons() -> void:
	for weapon in owned_weapons:
		if weapon.free_starting_ammo:
			ammo_state[weapon] = {"in_mag": weapon.magazine_size, "reserve": weapon.starting_reserve_ammo}

func buy_ammo(weapon: WeaponData, amount: int) -> bool:
	var total_cost = amount * weapon.ammo_price_cash
	if banked_cash >= total_cost:
		banked_cash -= total_cost
		var state = get_ammo_state(weapon)
		state.reserve += amount
		return true
	return false

func equip_weapon(weapon: WeaponData) -> void:
	if owned_weapons.has(weapon):
		equipped_weapon = weapon

func buy_weapon(weapon: WeaponData) -> bool:
	if banked_cash >= weapon.price_cash and not owned_weapons.has(weapon):
		banked_cash -= weapon.price_cash
		owned_weapons.append(weapon)
		return true
	return false
	
func buy_attachment(attachment: WeaponAttachment) -> bool:
	if banked_scrap >= attachment.price_scrap and not owned_attachments.has(attachment):
		banked_scrap -= attachment.price_scrap
		owned_attachments.append(attachment)
		return true
	return false

func equip_attachment(weapon: WeaponData, attachment: WeaponAttachment) -> void:
	if not owned_attachments.has(attachment):
		return
	match attachment.slot_type:
		"barrel":
			weapon.equipped_barrel = attachment
		"bolt":
			weapon.equipped_bolt = attachment
		"body":
			weapon.equipped_body = attachment

func unequip_attachment(weapon: WeaponData, slot_type: String) -> void:
	match slot_type:
		"barrel":
			weapon.equipped_barrel = null
		"bolt":
			weapon.equipped_bolt = null
		"body":
			weapon.equipped_body = null

func on_run_success(cash_bonus: int) -> void:
	last_run_summary = {
		"kills": run_kills,
		"damage": run_damage_dealt,
		"loot": run_loot.duplicate(),
		"scrap_earned": run_scrap,
		"cash_earned": cash_bonus
	}
	banked_scrap += run_scrap
	banked_cash += cash_bonus
	reset_run_stats()

func make_noise(pos: Vector2, volume: float) -> void:
	noise_made.emit(pos, volume)

func reset_health() -> void:
	player_health = max_player_health
