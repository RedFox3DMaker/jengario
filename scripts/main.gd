extends Node2D


var mouse_cursor_p1 = load("res://assets/ux/cursor_1.png")
@onready var start_screen = $StartScreen
@onready var end_screen = $EndScreen
@onready var level = $Level

@export var level_scene: PackedScene

func _on_start_screen_start_game() -> void:
	start_screen.hide()
	level.show()
	Input.set_custom_mouse_cursor(mouse_cursor_p1)


func _on_end_screen_exit_game() -> void:
	get_tree().quit()


func _on_end_screen_restart_game() -> void:
	end_screen.hide()
	level.queue_free()
	
	level = level_scene.instantiate()
	level.connect("game_over", _on_level_game_over)
	add_child(level)
	move_child(level, 0)
	
func _on_level_game_over() -> void:
	end_screen.show()
