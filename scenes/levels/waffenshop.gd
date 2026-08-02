extends Area2D

@export var shop_ui_scene: PackedScene

var player_in_range: bool = false
var shop_ui: CanvasLayer = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	shop_ui = shop_ui_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(shop_ui)

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		shop_ui.visible = not shop_ui.visible
		if shop_ui.visible:
			shop_ui.refresh_list()

func _on_body_entered(body: Node2D) -> void:
	print("Body entered waffenshop: ", body.name)
	if body.is_in_group("player"):
		player_in_range = true
		print("Player in range: true")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		shop_ui.visible = false
