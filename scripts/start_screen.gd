extends Control


class_name StartScreen


signal start_game(nb_stacks: int)
var nb_stacks: int = 5


func _on_start_button_pressed() -> void:
	self.start_game.emit(self.nb_stacks)


func _on_settings_button_pressed() -> void:
	$AcceptDialog.visible = true


func _on_accept_dialog_confirmed() -> void:
	self.nb_stacks = $AcceptDialog/Control/Label/SpinBox.value
