extends Resource
class_name WeaponData


@export var weapon_name: String = "Pistole"
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
