extends Control

signal restart_game
signal exit_game


func _on_exit_button_pressed() -> void:
	exit_game.emit()


func _on_restart_button_pressed() -> void:
	restart_game.emit()
