extends CanvasLayer

@onready var main_container: VBoxContainer = $Panel/MainContainer

var owned_weapons_list: Array[WeaponData] = []
var all_attachments: Array[WeaponAttachment] = []
var selected_weapon: WeaponData = null

const SLOT_TYPES = ["barrel", "bolt", "body"]
const SLOT_LABELS = {"barrel": "Lauf", "bolt": "Verschluss", "body": "Körper"}

func _ready() -> void:
	all_attachments = _load_all_attachments("res://resources/attachments/")

func _load_all_attachments(path: String) -> Array[WeaponAttachment]:
	var result: Array[WeaponAttachment] = []
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Attachment-Ordner nicht gefunden: " + path)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var resource = load(path + file_name)
			if resource is WeaponAttachment:
				result.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()

	return result

func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("ui_cancel"):
		visible = false
		GameState.ui_open = false

func refresh_list() -> void:
	for child in main_container.get_children():
		child.queue_free()

	var weapon_row = HBoxContainer.new()
	for weapon in owned_weapons_list:
		var weapon_button = Button.new()
		weapon_button.text = weapon.weapon_name
		weapon_button.disabled = weapon == selected_weapon
		weapon_button.pressed.connect(_on_weapon_selected.bind(weapon))
		weapon_row.add_child(weapon_button)
	main_container.add_child(weapon_row)

	if not selected_weapon:
		return

	for slot_type in SLOT_TYPES:
		var slot_header = Label.new()
		var currently_equipped = _get_equipped_in_slot(selected_weapon, slot_type)
		var equipped_text = currently_equipped.attachment_name if currently_equipped else "Leer"
		slot_header.text = "--- " + SLOT_LABELS[slot_type] + " (aktuell: " + equipped_text + ") ---"
		main_container.add_child(slot_header)

		if currently_equipped:
			var remove_row = HBoxContainer.new()
			var remove_label = Label.new()
			remove_label.text = "Attachment entfernen"
			remove_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			remove_row.add_child(remove_label)
			var remove_button = Button.new()
			remove_button.text = "Entfernen"
			remove_button.pressed.connect(_on_unequip_pressed.bind(slot_type))
			remove_row.add_child(remove_button)
			main_container.add_child(remove_row)

		for attachment in all_attachments:
			if attachment.slot_type != slot_type:
				continue
			if not _is_compatible(attachment, selected_weapon):
				continue

			var row = HBoxContainer.new()
			var label = Label.new()
			label.set_script(preload("res://scripts/tooltip_label.gd"))
			var is_owned = GameState.owned_attachments.has(attachment)
			var is_equipped = currently_equipped == attachment
			var status_text = " (ausgerüstet)" if is_equipped else (" (im Besitz)" if is_owned else " - " + str(attachment.price_scrap) + " Scrap")
			label.text = attachment.attachment_name + status_text
			label.tooltip_text = attachment.description
			label.mouse_filter = Control.MOUSE_FILTER_STOP
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var can_afford = GameState.banked_scrap >= attachment.price_scrap
			if not is_owned and not can_afford:
				label.add_theme_color_override("font_color", Color.RED)

			row.add_child(label)

			if is_equipped:
				pass
			elif is_owned:
				var equip_button = Button.new()
				equip_button.set_script(preload("res://scripts/tooltip_button.gd"))
				equip_button.text = "Ausrüsten"
				equip_button.tooltip_text = _get_stat_changes_text(attachment)
				equip_button.pressed.connect(_on_equip_pressed.bind(attachment))
				row.add_child(equip_button)
			else:
				var buy_button = Button.new()
				buy_button.set_script(preload("res://scripts/tooltip_button.gd"))
				buy_button.text = "Kaufen"
				buy_button.tooltip_text = _get_stat_changes_text(attachment)
				buy_button.disabled = not can_afford
				buy_button.pressed.connect(_on_buy_pressed.bind(attachment))
				row.add_child(buy_button)

			main_container.add_child(row)

func _get_equipped_in_slot(weapon: WeaponData, slot_type: String) -> WeaponAttachment:
	match slot_type:
		"barrel": return weapon.equipped_barrel
		"bolt": return weapon.equipped_bolt
		"body": return weapon.equipped_body
	return null

func _is_compatible(attachment: WeaponAttachment, weapon: WeaponData) -> bool:
	if attachment.allowed_weapon_types.is_empty():
		return true
	return attachment.allowed_weapon_types.has(weapon.weapon_type)

func _on_weapon_selected(weapon: WeaponData) -> void:
	selected_weapon = weapon
	refresh_list()

func _on_buy_pressed(attachment: WeaponAttachment) -> void:
	if GameState.buy_attachment(attachment):
		refresh_list()

func _on_equip_pressed(attachment: WeaponAttachment) -> void:
	GameState.equip_attachment(selected_weapon, attachment)
	refresh_list()

func _on_unequip_pressed(slot_type: String) -> void:
	GameState.unequip_attachment(selected_weapon, slot_type)
	refresh_list()
	
func _get_stat_changes_text(attachment: WeaponAttachment) -> String:
	var stats = {
		"Schaden": attachment.damage_mult,
		"Feuerrate": attachment.fire_rate_mult,
		"Geschossgeschw.": attachment.bullet_speed_mult,
		"Streuung": attachment.spread_mult,
		"Lautstärke": attachment.volume_mult,
		"Reichweite": attachment.range_mult,
		"Gewicht": attachment.weight_mult,
	}
	var lines: Array = []
	for stat_name in stats:
		var mult = stats[stat_name]
		if not is_equal_approx(mult, 1.0):
			var percent = (mult - 1.0) * 100.0
			var sign_str = "+" if percent > 0 else ""
			lines.append(stat_name + ": " + sign_str + "%.0f" % percent + "%")
	return "\n".join(lines) if lines.size() > 0 else "Keine Werteänderung"
