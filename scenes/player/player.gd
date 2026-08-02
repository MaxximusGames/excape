extends CharacterBody2D

@export var speed: float = 200.0


var can_shoot: bool = true
var inventory: Array = []


func _ready() -> void:
	add_to_group("player")
	
func take_damage(amount: float) -> void:
	GameState.player_health -= amount
	if GameState.player_health <= 0:
		die()

func die() -> void:
	GameState.on_run_failed()
	get_tree().change_scene_to_file("res://scenes/levels/game_over.tscn")

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var weight_multiplier = 1.0
	if GameState.equipped_weapon:
		weight_multiplier = 1.0 / GameState.equipped_weapon.weight
	velocity = input_direction * speed * weight_multiplier
	move_and_slide()

	look_at(get_global_mouse_position())

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if not GameState.equipped_weapon:
		return
	can_shoot = false
	var weapon = GameState.equipped_weapon
	var bullet = weapon.bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	GameState.make_noise(global_position, weapon.volume)

	var base_direction = (get_global_mouse_position() - global_position).normalized()
	var spread_radians = deg_to_rad(weapon.spread)
	var random_angle_offset = randf_range(-spread_radians / 2.0, spread_radians / 2.0)
	var final_direction = base_direction.rotated(random_angle_offset)

	bullet.direction = final_direction
	bullet.damage = weapon.damage
	bullet.speed = weapon.bullet_speed
	bullet.max_range = weapon.range

	await get_tree().create_timer(weapon.fire_rate).timeout
	can_shoot = true

func collect_item(item_name: String, value: int) -> void:
	GameState.add_item(item_name, value)
