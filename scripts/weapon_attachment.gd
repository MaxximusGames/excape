extends Resource
class_name WeaponAttachment

@export var attachment_name: String = "Attachment Name"
@export_multiline var description: String = "Beschreibung"
@export var slot_type: String = "barrel"  # "barrel", "bolt", "body"
@export var allowed_weapon_types: Array[String] = []  # leer = alle Waffentypen erlaubt
@export var price_scrap: int = 50

@export var damage_mult: float = 1.0
@export var fire_rate_mult: float = 1.0
@export var bullet_speed_mult: float = 1.0
@export var spread_mult: float = 1.0
@export var volume_mult: float = 1.0
@export var range_mult: float = 1.0
@export var weight_mult: float = 1.0
