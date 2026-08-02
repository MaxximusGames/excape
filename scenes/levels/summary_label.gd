extends CanvasLayer

@onready var summary_label: Label = $SummaryLabel

func _ready() -> void:
	var summary = GameState.last_run_summary

	var grouped_loot: Dictionary = {}
	for item in summary.loot:
		if grouped_loot.has(item.name):
			grouped_loot[item.name] += item.value
		else:
			grouped_loot[item.name] = item.value

	var loot_text = ""
	for item_name in grouped_loot:
		loot_text += "- " + item_name + " (" + str(grouped_loot[item_name]) + ")\n"

	summary_label.text = "Erfolgreich extrahiert!\n\n"
	summary_label.text += "Kills: " + str(summary.kills) + "\n"
	summary_label.text += "Schaden verursacht: " + str(int(summary.damage)) + "\n"
	summary_label.text += "Scrap verdient: " + str(summary.scrap_earned) + "\n"
	summary_label.text += "Cash-Bonus: " + str(summary.cash_earned) + "\n\n"
	summary_label.text += "Loot:\n" + loot_text
	summary_label.text += "\nHalte [E] für Homebase"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://scenes/levels/homebase.tscn")
