extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_count: int = 3
@export var spawn_spread: float = 80.0
@export var respawn_distance: float = 500.0
@export var respawn_delay: float = 15.0

var active_enemies: Array = []
var is_cleared: bool = false
var player_away_timer: float = 0.0
var player_ref: Node2D = null

func _ready() -> void:
	print("Spawn-Punkt aktiv an Position: ", global_position)
	player_ref = get_tree().get_first_node_in_group("player")
	spawn_wave()

func _process(delta: float) -> void:
	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))

	if active_enemies.is_empty() and not is_cleared:
		is_cleared = true
		player_away_timer = 0.0
		print("Spawn-Punkt geleert, warte auf Spieler-Abstand...")

	if is_cleared and player_ref:
		var distance = global_position.distance_to(player_ref.global_position)
		if distance >= respawn_distance:
			player_away_timer += delta
			if player_away_timer >= respawn_delay:
				print("Respawn-Bedingung erfüllt, spawne neu!")
				spawn_wave()
		else:
			player_away_timer = 0.0

func spawn_wave() -> void:
	is_cleared = false
	active_enemies.clear()
	for i in enemy_count:
		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child.call_deferred(enemy)
		var offset = Vector2(randf_range(-spawn_spread, spawn_spread), randf_range(-spawn_spread, spawn_spread))
		enemy.global_position = global_position + offset
		active_enemies.append(enemy)
		print("Gegner gespawnt an: ", enemy.global_position, " | Insgesamt aktiv: ", active_enemies.size())
