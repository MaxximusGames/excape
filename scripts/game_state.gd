extends Node
signal noise_made(position: Vector2, volume: float)

var banked_scrap: int = 0
var banked_cash: int = 1500

var run_scrap: int = 0
var run_loot: Array = []
var run_kills: int = 0
var run_damage_dealt: float = 0.0

var player_health: float = 100.0
var max_player_health: float = 100.0

var owned_weapons: Array[WeaponData] = []
var equipped_weapon: WeaponData = null

var last_run_summary: Dictionary = {}

func _ready() -> void:
	owned_weapons.append(preload("res://resources/weapons/pistol.tres"))
	equipped_weapon = owned_weapons[0]

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

func equip_weapon(weapon: WeaponData) -> void:
	if owned_weapons.has(weapon):
		equipped_weapon = weapon

func buy_weapon(weapon: WeaponData) -> bool:
	if banked_cash >= weapon.price_cash and not owned_weapons.has(weapon):
		banked_cash -= weapon.price_cash
		owned_weapons.append(weapon)
		return true
	return false

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
