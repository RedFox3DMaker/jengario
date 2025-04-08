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
	play_music("MENU", true)


## Change the current music playing.
func play_music(sound_name: String, loop=false, volume=0):
	if sound_name not in AudioManager.sounds: 
		return
	
	var resource: Resource = AudioManager.sounds[sound_name]
	if resource.resource_path == music_player.stream.resource_path:
		return

	if music_player.playing:
		music_player.stop()

	music_player.stream = resource
	music_player.play()
	music_player.stream.loop = loop
	music_player.volume_db = volume


## Called after a click on the Start Screen start button.
## Hides the Start Screen, show the level, and build the tower.
func _on_buttons_controls_start_game(nb_stacks_settings: int, nb_players_settings: int) -> void:	
	# clean old level
	if level:
		level.queue_free()
	
	# hide the controls
	screens.hide_end_screen()
	screens.hide()
	buttons_controls.hide()
		
	# instantiate the level
	level = level_scene.instantiate()
	
	# configure the level
	level.nb_players = nb_players_settings
	level.nb_stacks = nb_stacks_settings
	
	# add it to the tree
	add_child(level)
	move_child(level, 0)
	
	# connect the game over signal
	level.game_over.connect(_on_level_game_over)
	

	play_music("GAME", true)


## Quit the game on End Screen Exit button click.
func _on_buttons_controls_exit_game() -> void:
	get_tree().quit()


## Show the End Screen on Game Over.
func _on_level_game_over(winner: StringName) -> void:
	screens.show()	
	buttons_controls.show()
	screens.show_end_screen(winner, buttons_controls.nb_players)
	play_music("END", true, -6)
