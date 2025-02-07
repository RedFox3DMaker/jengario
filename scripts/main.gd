extends Node2D


var current_player: int = 0
var mouse_cursor: Array[Resource] = [
	load("res://assets/ux/cursor_1.png"),
	load("res://assets/ux/cursor_2.png"),
	load("res://assets/ux/cursor_3.png"),
	load("res://assets/ux/cursor_4.png")
	]
var mouse_cursor_drag: Array[Resource] = [
	load("res://assets/ux/cursor_drag_1.png"),
	load("res://assets/ux/cursor_drag_2.png"),
	load("res://assets/ux/cursor_drag_3.png"),
	load("res://assets/ux/cursor_drag_4.png")
	]
var mouse_cursor_hotspot: Array[Vector2] = [
	Vector2(15,8),
	Vector2(19,9),
	Vector2(34,42),
	Vector2(14,4),
]
var nb_stacks: int = 5
var nb_players: int = 4


@onready var hud: HUD = $HUD
@onready var level: Level = $Level
@onready var music_player: AudioStreamPlayer = $MusicPlayer


@export var level_scene: PackedScene


func _set_current_player(index: int) -> void:
	"""
	Switch current player turn and change mouse cursors.
	"""
	self.current_player = wrapi(index, 0, self.nb_players)
	self.hud.information_screen.set_player(self.current_player)
	Input.set_custom_mouse_cursor(self.mouse_cursor[self.current_player], Input.CURSOR_ARROW, self.mouse_cursor_hotspot[self.current_player])


func _input(event: InputEvent) -> void:
	# do not change cursor when button controls is shown
	if self.hud.buttons_controls.visible: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_custom_mouse_cursor(self.mouse_cursor_drag[self.current_player], Input.CURSOR_ARROW, self.mouse_cursor_hotspot[self.current_player])
		elif event.is_released():
			Input.set_custom_mouse_cursor(self.mouse_cursor[self.current_player], Input.CURSOR_ARROW, self.mouse_cursor_hotspot[self.current_player])
			


func _ready() -> void:
	"""
	Called when scene has been added to the tree.
	"""
	self.play_music("res://assets/sounds/menu song mdj.mp3", true)

	# connect start and exit buttons
	self.hud.buttons_controls.start_game.connect(self._on_buttons_controls_start_game)
	self.hud.buttons_controls.exit_game.connect(self._on_buttons_controls_exit_game)


func _on_buttons_controls_start_game(nb_stacks_settings: int, nb_players_settings: int) -> void:
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

	# update the players
	self.nb_players = nb_players_settings
	#self.level.show_players(true)
	self.level.build_players(self.nb_players)
	self.hud.information_screen.show_players_scores(self.nb_players)
	self.connect_players_update_score()

	# show the level
	self.hud.show_game_screen()

	self._set_current_player(0)
	self.hud.information_screen.reset_players_score()
	self.hud.information_screen.set_player(0)

	self.play_music("res://assets/sounds/mdj gameplay.mp3", true)


func _on_buttons_controls_exit_game() -> void:
	"""
	Quit the game on End Screen Exit button click.
	"""
	get_tree().quit()


func _on_level_game_over() -> void:
	"""
	Show the End Screen on Game Over.
	"""
	var winner_index = self.hud.get_winner_index(self.current_player)
	var winner_player: Player = self.level.players[winner_index]
	self.hud.show_end_screen(winner_player.sprite.animation)
	self.level.remove_players()
	Input.set_custom_mouse_cursor(null)
	self.play_music("res://assets/sounds/Victory and ending song.mp3", false, -6)


func play_music(sound_path: String, loop=false, volume=0):
	"""
	Change the current music playing.
	"""
	if sound_path == self.music_player.stream.resource_path:
		return

	if self.music_player.playing:
		self.music_player.stop()

	self.music_player.stream = load(sound_path)
	self.music_player.play()
	self.music_player.stream.loop = loop
	self.music_player.volume_db = volume


func connect_brick_dropped() -> void:
	"""
	Connect the brick drop signal to update the current player.
	"""
	for brick: Brick in get_tree().get_nodes_in_group("bricks"):
		brick.dropped.connect(self._on_brick_dropped)


func connect_players_update_score() -> void:
	"""
	Connect players update_score
	"""
	for player: Player in self.level.players:
		player.update_score.connect(self._on_player_update_score)


func _on_brick_dropped() -> void:
	"""
	Update the current player when the Brick dropped signal is received, only if
	the End Screen is not shown.
	"""
	if not self.hud.end_screen.visible:
		self._set_current_player(self.current_player + 1)


func _on_player_update_score(player: Player) -> void:
	"""
	update the player score
	"""
	var player_num = self.level.players.find(player)
	self.hud.information_screen.update_player_score(player_num)
	if not self.hud.end_screen.visible:
		self._set_current_player(self.current_player + 1)
