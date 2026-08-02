extends Area2D

@export var speed: float = 600.0
@export var damage: float = 10.0
@export var max_range: float = 800.0

var direction: Vector2 = Vector2.RIGHT
var distance_traveled: float = 0.0

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement
	distance_traveled += movement.length()
	if distance_traveled >= max_range:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
