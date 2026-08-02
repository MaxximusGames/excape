extends CanvasLayer

@onready var scrap_label: Label = $ScrapLabel
@onready var cash_label: Label = $CashLabel

func _process(delta: float) -> void:
	scrap_label.text = "Scrap: " + str(GameState.banked_scrap)
	cash_label.text = "Cash: " + str(GameState.banked_cash)
