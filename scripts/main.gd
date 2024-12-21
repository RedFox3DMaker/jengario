extends Node2D


var mouse_cursor_p1 = load("res://assets/ux/cursor_1.png")
@onready var start_screen = $StartScreen
@onready var end_screen = $EndScreen
@onready var level = $Level
@onready var music_player = $MusicPlayer

@export var level_scene: PackedScene

func _ready() -> void:
	play_music("res://assets/sounds/menu song mdj.mp3")

func _on_start_screen_start_game(nb_levels: int) -> void:
	start_screen.hide()
	if nb_levels != level.nb_stacks:
		level.nb_stacks = nb_levels
		level.init_tower()
	level.show()
	level.unfreeze_tower()
	Input.set_custom_mouse_cursor(mouse_cursor_p1)
	play_music("res://assets/sounds/mdj gameplay.mp3")


func _on_end_screen_exit_game() -> void:
	get_tree().quit()


func _on_end_screen_restart_game() -> void:
	end_screen.hide()
	level.queue_free()
	
	level = level_scene.instantiate()
	level.connect("game_over", _on_level_game_over)
	add_child(level)
	move_child(level, 0)
	play_music("res://assets/sounds/mdj gameplay.mp3")
	level.unfreeze_tower()
	
func _on_level_game_over() -> void:
	end_screen.show()
	play_music("res://assets/sounds/Victory and ending song.mp3")
	
func play_music(sound_path: String):
	if sound_path == music_player.stream.resource_path:
		return 
		
	if music_player.playing:
		music_player.stop()
	
	music_player.stream = load(sound_path)
	music_player.play()
	
