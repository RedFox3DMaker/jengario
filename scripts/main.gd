extends Node2D

## Main script
## 
## Manage the game lifecycle.

@export var level_scene: PackedScene

@onready var level: Level = null
@onready var screens: Screens = $Screens
@onready var buttons_controls: ButtonsControls = $ButtonsControls
@onready var music_player: AudioStreamPlayer = $MusicPlayer


## Called when scene has been added to the tree.
func _ready() -> void:
	play_music("res://assets/sounds/menu song mdj.mp3", true)


## Change the current music playing.
func play_music(sound_path: String, loop=false, volume=0):
	if sound_path == music_player.stream.resource_path:
		return

	if music_player.playing:
		music_player.stop()

	music_player.stream = load(sound_path)
	music_player.play()
	music_player.stream.loop = loop
	music_player.volume_db = volume


## Called after a click on the Start Screen start button.
## Hides the Start Screen, show the level, and build the tower.
func _on_buttons_controls_start_game(nb_stacks_settings: int, nb_players_settings: int) -> void:	
	# clean old level
	if level:
		level.queue_free()
		
	# instantiate the level and add it to the tree
	level = level_scene.instantiate()
	add_child(level)
	move_child(level, 0)
	
	# configure the level
	level.nb_players = nb_players_settings
	level.nb_stacks = nb_stacks_settings
	
	# connect the game over signal
	level.game_over.connect(_on_level_game_over)
	
	# show the level
	screens.hide()
	buttons_controls.hide()

	play_music("res://assets/sounds/mdj gameplay.mp3", true)


## Quit the game on End Screen Exit button click.
func _on_buttons_controls_exit_game() -> void:
	get_tree().quit()


## Show the End Screen on Game Over.
func _on_level_game_over(winner: StringName) -> void:
	screens.show()
	buttons_controls.show()
	screens.show_end_screen(winner, buttons_controls.nb_players)
	play_music("res://assets/sounds/Victory and ending song.mp3", false, -6)
