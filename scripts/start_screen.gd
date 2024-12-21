extends Control

signal start_game(nb_levels: int)
var nb_levels: int = 5

func _on_start_button_pressed() -> void:
	start_game.emit(nb_levels)


func _on_settings_button_pressed() -> void:
	$AcceptDialog.visible = true


func _on_accept_dialog_confirmed() -> void:
	nb_levels = $AcceptDialog/Control/Label/SpinBox.value
