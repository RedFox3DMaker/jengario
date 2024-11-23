extends Node2D


var mouse_cursor_p1 = load("res://assets/ux/cursor_1.png")
func _on_start_screen_start_game() -> void:
	$StartScreen.hide()
	$Level.show()
	Input.set_custom_mouse_cursor(mouse_cursor_p1)


func _on_end_screen_exit_game() -> void:
	pass


func _on_end_screen_restart_game() -> void:
	$EndScreen.hide()
