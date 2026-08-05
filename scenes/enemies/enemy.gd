extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: float = 30.0
@export var pickup_scene: PackedScene
@export var bullet_scene: PackedScene
@export var attack_range: float = 250.0
@export var detection_range: float = 400.0
@export var fire_rate: float = 1.2
@export var memory_duration: float = 5.0
@export var investigate_arrival_distance: float = 20.0
@export var wander_radius: float = 60.0
@export var wander_interval: float = 3.0
@export var wander_speed_factor: float = 0.4
@export var fov_angle: float = 150.0

var health: float
var player_ref: Node2D = null
var can_shoot: bool = true
var awareness_timer: float = 0.0
var can_see_player: bool = false
var last_known_position: Vector2 = Vector2.ZERO

var home_position: Vector2 = Vector2.ZERO
var wander_target: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

@onready var health_bar: ProgressBar = $HealthBarContainer/ProgressBar

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	player_ref = get_tree().get_first_node_in_group("player")
	health_bar.value = 100
	health_bar.visible = false
	GameState.noise_made.connect(_on_noise_made)

	home_position = global_position
	wander_target = global_position

func _physics_process(delta: float) -> void:
	if not player_ref:
		return
	
	visible = player_ref.can_see_point(global_position)
	
	var distance_to_player := global_position.distance_to(player_ref.global_position)
	can_see_player = distance_to_player <= detection_range and is_player_in_fov() and has_line_of_sight_to_player()

	if can_see_player:
		awareness_timer = memory_duration
		last_known_position = player_ref.global_position

	if awareness_timer > 0:
		awareness_timer -= delta
	else:
		wander(delta)
		return

	if can_see_player and distance_to_player <= attack_range:
		velocity = Vector2.ZERO
		look_at(player_ref.global_position)
		if can_shoot:
			shoot()
		move_and_slide()
		return

	var target_position = player_ref.global_position if can_see_player else last_known_position
	var distance_to_target = global_position.distance_to(target_position)

	if distance_to_target > investigate_arrival_distance:
		var direction := (target_position - global_position).normalized()
		velocity = direction * speed
		look_at(target_position)
	else:
		velocity = Vector2.ZERO

	move_and_slide()
		

func wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0:
		wander_timer = wander_interval
		var random_offset = Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
		wander_target = home_position + random_offset

	var distance_to_wander_target = global_position.distance_to(wander_target)
	if distance_to_wander_target > 5.0:
		var direction := (wander_target - global_position).normalized()
		velocity = direction * speed * wander_speed_factor
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, 3.0 * delta)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func has_line_of_sight_to_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player_ref.global_position)
	query.collision_mask = 1 << 7  # obstacles-Layer (Bit-Nummer anpassen)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result.is_empty()
	
func is_player_in_fov() -> bool:
	var direction_to_player = (player_ref.global_position - global_position).normalized()
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var angle_to_player = rad_to_deg(facing_direction.angle_to(direction_to_player))
	return abs(angle_to_player) <= fov_angle / 2.0
	
func shoot() -> void:
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = (player_ref.global_position - global_position).normalized()
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(amount: float) -> void:
	health -= amount
	GameState.run_damage_dealt += amount
	health_bar.visible = true
	health_bar.value = (health / max_health) * 100
	if health <= 0:
		GameState.run_kills += 1
		drop_loot()
		queue_free()

func _on_noise_made(noise_position: Vector2, volume: float) -> void:
	var distance = global_position.distance_to(noise_position)
	if distance <= volume and not can_see_player:
		awareness_timer = memory_duration
		last_known_position = noise_position

func drop_loot() -> void:
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = global_position
