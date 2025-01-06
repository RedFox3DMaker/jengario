extends Control


class_name EndScreen


signal restart_game
signal exit_game


func _on_exit_button_pressed() -> void:
	self.exit_game.emit()


func _on_restart_button_pressed() -> void:
	self.restart_game.emit()
