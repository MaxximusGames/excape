extends CharacterBody2D

@export var speed: float = 200.0
@export var vision_radius: float = 1500.0


var is_reloading: bool = false
var can_shoot: bool = true
var inventory: Array = []

@onready var reload_bar_container: Node2D = $ReloadBarContainer
@onready var reload_bar: ProgressBar = $ReloadBarContainer/ProgressBar

func _ready() -> void:
	add_to_group("player")
	
func take_damage(amount: float) -> void:
	GameState.player_health -= amount
	if GameState.player_health <= 0:
		die()

func die() -> void:
	GameState.on_run_failed()
	get_tree().change_scene_to_file("res://scenes/levels/game_over.tscn")

func _process(delta: float) -> void:
	reload_bar_container.global_position = global_position + Vector2(-10, -20)
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var weight_multiplier = 1.0
	if GameState.equipped_weapon:
		weight_multiplier = 1.0 / GameState.equipped_weapon.get_effective_weight()
	velocity = input_direction * speed * weight_multiplier
	move_and_slide()

	look_at(get_global_mouse_position())
	if Input.is_action_pressed("shoot") and can_shoot and not GameState.ui_open:
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()

func shoot() -> void:
	if not GameState.equipped_weapon or is_reloading:
		return

	var weapon = GameState.equipped_weapon
	var ammo = GameState.get_ammo_state(weapon)

	if ammo.in_mag <= 0:
		reload()
		return

	can_shoot = false
	ammo.in_mag -= 1

	var bullet = weapon.bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position

	var base_direction = (get_global_mouse_position() - global_position).normalized()
	var spread_radians = deg_to_rad(weapon.get_effective_spread())
	var random_angle_offset = randf_range(-spread_radians / 2.0, spread_radians / 2.0)
	bullet.direction = base_direction.rotated(random_angle_offset)
	bullet.damage = weapon.get_effective_damage()
	bullet.speed = weapon.get_effective_bullet_speed()
	bullet.max_range = weapon.get_effective_range()

	GameState.make_noise(global_position, weapon.get_effective_volume())

	await get_tree().create_timer(weapon.get_effective_fire_rate()).timeout
	can_shoot = true

func can_see_point(point: Vector2) -> bool:
	if global_position.distance_to(point) > vision_radius:
		return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, point)
	query.collision_mask = 1 << 7  # obstacles
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result.is_empty()

func reload() -> void:
	if not GameState.equipped_weapon or is_reloading:
		return
	var weapon = GameState.equipped_weapon
	var ammo = GameState.get_ammo_state(weapon)
	if ammo.in_mag >= weapon.magazine_size or ammo.reserve <= 0:
		return

	is_reloading = true
	reload_bar_container.visible = true
	reload_bar.value = 0

	var elapsed = 0.0
	while elapsed < weapon.reload_time:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		reload_bar.value = (elapsed / weapon.reload_time) * 100

	GameState.reload_weapon(weapon)
	is_reloading = false
	reload_bar_container.visible = false

func collect_item(item_name: String, value: int) -> void:
	GameState.add_item(item_name, value)
