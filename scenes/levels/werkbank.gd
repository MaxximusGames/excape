extends Area2D

@export var workbench_ui_scene: PackedScene

var player_in_range: bool = false
var workbench_ui: CanvasLayer = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	workbench_ui = workbench_ui_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(workbench_ui)

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		workbench_ui.visible = not workbench_ui.visible
		if workbench_ui.visible:
			GameState.ui_open = true
			workbench_ui.owned_weapons_list = GameState.owned_weapons
			if not workbench_ui.selected_weapon and workbench_ui.owned_weapons_list.size() > 0:
				workbench_ui.selected_weapon = workbench_ui.owned_weapons_list[0]
			workbench_ui.refresh_list()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		workbench_ui.visible = false
		GameState.ui_open = false
