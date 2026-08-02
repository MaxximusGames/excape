extends CanvasLayer

@onready var item_list_container: VBoxContainer = $Panel/VBoxContainer

var available_weapons: Array[WeaponData] = []

func _ready() -> void:
	available_weapons = [
		preload("res://resources/weapons/pistol.tres"),
		preload("res://resources/weapons/rifle.tres"),
		preload("res://resources/weapons/mg.tres"),
		preload("res://resources/weapons/mp.tres"),
	]

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
		var owned_text = " (bereits gekauft)" if GameState.owned_weapons.has(weapon) else ""
		label.text = weapon.weapon_name + " - " + str(weapon.price_cash) + " Cash" + owned_text
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var can_afford = GameState.banked_cash >= weapon.price_cash
		if not can_afford and owned_text == "":
			label.add_theme_color_override("font_color", Color.RED)

		row.add_child(label)

		if not GameState.owned_weapons.has(weapon):
			var buy_button = Button.new()
			buy_button.text = "Kaufen"
			buy_button.disabled = not can_afford
			buy_button.pressed.connect(_on_buy_pressed.bind(weapon))
			row.add_child(buy_button)
		elif not weapon.free_starting_ammo:
			var ammo = GameState.get_ammo_state(weapon)
			var bundle_size = weapon.magazine_size
			var ammo_cost = bundle_size * weapon.ammo_price_cash
			var ammo_button = Button.new()
			ammo_button.text = "+" + str(bundle_size) + " Munition (" + str(ammo_cost) + " Cash) - im Besitz: " + str(ammo.reserve)
			ammo_button.disabled = GameState.banked_cash < ammo_cost
			ammo_button.pressed.connect(_on_buy_ammo_pressed.bind(weapon))
			row.add_child(ammo_button)

		item_list_container.add_child(row)

func _on_buy_ammo_pressed(weapon: WeaponData) -> void:
	if GameState.buy_ammo(weapon, 20):
		refresh_list()

func _on_buy_pressed(weapon: WeaponData) -> void:
	if GameState.buy_weapon(weapon):
		refresh_list()
	else:
		print("Nicht genug Cash!")
