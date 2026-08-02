extends CanvasLayer

@onready var item_list_container: VBoxContainer = $Panel/VBoxContainer

var available_weapons: Array[WeaponData] = []

func _ready() -> void:
	available_weapons = GameState.owned_weapons

func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		visible = false

func open_shop() -> void:
	visible = true
	GameState.ui_open = true
	refresh_list()

func close_shop() -> void:
	visible = false
	GameState.ui_open = false

func refresh_list() -> void:
	for child in item_list_container.get_children():
		child.queue_free()

	for weapon in available_weapons:
		var row = HBoxContainer.new()

		var label = Label.new()
		var owned_text = " (bereits ausgerüstet)" if GameState.equipped_weapon == weapon else ""
		label.text = weapon.weapon_name + owned_text
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		row.add_child(label)

		if not GameState.equipped_weapon == weapon:
			var equip_button = Button.new()
			equip_button.text = "Ausrüsten"
			equip_button.pressed.connect(_on_equip_pressed.bind(weapon))
			row.add_child(equip_button)

		item_list_container.add_child(row)

func _on_equip_pressed(weapon: WeaponData) -> void:
	GameState.equip_weapon(weapon)
	refresh_list()
