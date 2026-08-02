extends Resource
class_name WeaponData

@export var weapon_name: String = "Pistole"
@export var weapon_type: String = "pistol"  # "pistol", "rifle", "smg", "mg"
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
@export var damage: float = 10.0
@export var bullet_speed: float = 1000.0
@export var spread: float = 5.0
@export var volume: float = 500.0
@export var range: float = 800.0
@export var weight: float = 0.7
@export var price_cash: int = 50
@export var magazine_size: int = 12
@export var starting_reserve_ammo: int = 60
@export var free_starting_ammo: bool = false
@export var ammo_price_cash: int = 2
@export var reload_time: float = 1.5

@export var equipped_barrel: WeaponAttachment = null
@export var equipped_bolt: WeaponAttachment = null
@export var equipped_body: WeaponAttachment = null

func get_effective_damage() -> float:
	return damage * _get_mult("damage_mult")

func get_effective_fire_rate() -> float:
	return fire_rate / _get_mult("fire_rate_mult")

func get_effective_bullet_speed() -> float:
	return bullet_speed * _get_mult("bullet_speed_mult")

func get_effective_spread() -> float:
	return spread * _get_mult("spread_mult")

func get_effective_volume() -> float:
	return volume * _get_mult("volume_mult")

func get_effective_range() -> float:
	return range * _get_mult("range_mult")

func get_effective_weight() -> float:
	return weight * _get_mult("weight_mult")

func get_attachments() -> Array:
	var list: Array = []
	if equipped_barrel: list.append(equipped_barrel)
	if equipped_bolt: list.append(equipped_bolt)
	if equipped_body: list.append(equipped_body)
	return list

func _get_mult(stat_name: String) -> float:
	var total := 1.0
	for attachment in get_attachments():
		total *= attachment.get(stat_name)
	return total
