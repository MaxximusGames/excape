extends Button

func _make_custom_tooltip(for_text: String) -> Object:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var tooltip_label = Label.new()
	tooltip_label.text = for_text
	tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	tooltip_label.custom_minimum_size = Vector2(220, 0)
	panel.add_child(tooltip_label)

	return panel
