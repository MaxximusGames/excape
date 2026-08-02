extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var max_enemies: int = 10
@export var spawn_radius_min: float = 300.0
@export var spawn_radius_max: float = 700.0

var player_ref: Node2D = null
var spawn_timer: float = 0.0

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		try_spawn_enemy()

func try_spawn_enemy() -> void:
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()
	if current_enemies >= max_enemies:
		return

	if not player_ref:
		return

	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_position = player_ref.global_position + Vector2(cos(angle), sin(angle)) * distance

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_position
