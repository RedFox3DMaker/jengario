extends Node2D


var current_player: int = 0
var mouse_cursor: Array[Resource] = [
	load("res://assets/ux/cursor_1.png"),
	load("res://assets/ux/cursor_2.png"),
	load("res://assets/ux/cursor_3.png"),
	load("res://assets/ux/cursor_4.png")
	]
var nb_stacks: int = 5
var buttons_controls: ButtonsControls
var information_screen: InformationScreen


@onready var hud: HUD = $HUD
@onready var level: Level = $Level
@onready var music_player: AudioStreamPlayer = $MusicPlayer


@export var level_scene: PackedScene


func _set_current_player(index: int) -> void:
	"""
	Switch current player turn and change mouse cursors.
	"""
	self.current_player = wrapi(index, 0, 4)
	Input.set_custom_mouse_cursor(self.mouse_cursor[self.current_player])
	self.information_screen.set_player(self.current_player + 1)


func _ready() -> void:
	"""
	Called when scene has been added to the tree.
	"""
	self.play_music("res://assets/sounds/menu song mdj.mp3")
	self.information_screen = hud.get_information_screen()
	
	self.buttons_controls = hud.get_buttons_controls()
	self.buttons_controls.start_game.connect(self._on_buttons_controls_start_game)
	self.buttons_controls.exit_game.connect(self._on_buttons_controls_exit_game)


func _on_buttons_controls_start_game(nb_stacks_settings: int) -> void:
	"""
	Called after a click on the Start Screen start button.
	Hides the Start Screen, show the level, and build the tower.
	"""
	# clean the old tower
	if self.level.tower:
		self.level.tower.remove_bricks()
	
	# create the tower
	self.nb_stacks = nb_stacks_settings
	self.level.build_tower(self.nb_stacks)
	self.level.unfreeze_tower()
	self.connect_brick_dropped()
	
	# show the level
	self.hud.show_game_screen()
	
	self._set_current_player(0)
	self.information_screen.set_player(1)
	
	self.play_music("res://assets/sounds/mdj gameplay.mp3")


func _on_buttons_controls_exit_game() -> void:
	"""
	Quit the game on End Screen Exit button click.
	"""
	get_tree().quit()


func _on_level_game_over() -> void:
	"""
	Show the End Screen on Game Over.
	"""
	self.hud.show_end_screen()
	Input.set_custom_mouse_cursor(null)
	self.play_music("res://assets/sounds/Victory and ending song.mp3")


func play_music(sound_path: String):
	"""
	Change the current music playing.
	"""
	if sound_path == self.music_player.stream.resource_path:
		return

	if self.music_player.playing:
		self.music_player.stop()

	self.music_player.stream = load(sound_path)
	self.music_player.play()


func connect_brick_dropped() -> void:
	"""
	Connect the brick drop signal to update the current player.
	"""
	for brick: Brick in get_tree().get_nodes_in_group("bricks"):
		brick.dropped.connect(self._on_brick_dropped)


func _on_brick_dropped() -> void:
	"""
	Update the current player when the Brick dropped signal is received, only if
	the End Screen is not shown.
	"""
	if not self.hud.end_screen.visible:
		self._set_current_player(self.current_player + 1)
