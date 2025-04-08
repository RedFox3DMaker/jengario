class_name Level
extends Node2D

## Level script
## 
## Manage the level lifecycle

signal game_over(winner: StringName)

@export var tower_scene: PackedScene
@export var player_scene: PackedScene

var is_game_over = false
var tower: Tower = null
var players: Array[Player] = []

var current_player: int = 0
var nb_stacks: int = 5
var nb_players: int = 4

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
	Vector2(10,40),
	Vector2(19,9),
	Vector2(34,42),
	Vector2(14,4),
]

@onready var players_origins: Array[Marker2D] = [
	$"PlayersOrigins/Player1Origin",
	$"PlayersOrigins/Player2Origin",
	$"PlayersOrigins/Player3Origin",
	$"PlayersOrigins/Player4Origin"
]
@onready var tower_origin: Marker2D = $TowerOrigin
@onready var information_screen: InformationScreen = $InformationScreen


## Scene instantiation
func _ready() -> void:
	# creates the tower
	__build_tower()
	__unfreeze_tower()

	# update the players
	__build_players()
	information_screen.show_players_scores(nb_players)

	__set_current_player(0)
	information_screen.set_player(0)
	information_screen.reset_players_score()


## check the game over condition
func _physics_process(_delta: float) -> void:
	# do not process physics anymore if the game is over
	if is_game_over: return
	if tower:
		if tower.is_collasping():
			# play the tower fall sound
			is_game_over = true
			AudioManager.play("TOWER_FALL")
		elif not tower.has_bricks():
			is_game_over = true

	if is_game_over:
		# reset the mouse cursor
		Input.set_custom_mouse_cursor(null)
		
		# compute the winner from the score
		var winner_name = __get_winner_index()
		game_over.emit(winner_name)


## Change cursor while left click is maintained
func _input(event: InputEvent) -> void:
	if is_game_over: 
		Input.set_custom_mouse_cursor(null)
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_custom_mouse_cursor(mouse_cursor_drag[current_player], Input.CURSOR_ARROW, mouse_cursor_hotspot[current_player])
		elif event.is_released():
			Input.set_custom_mouse_cursor(mouse_cursor[current_player], Input.CURSOR_ARROW, mouse_cursor_hotspot[current_player])


## Switch current player turn and change mouse cursors.
func __set_current_player(index: int) -> void:
	current_player = wrapi(index, 0, nb_players)
	information_screen.set_player(current_player)
	Input.set_custom_mouse_cursor(mouse_cursor[current_player], Input.CURSOR_ARROW, mouse_cursor_hotspot[current_player])


func __build_tower() -> void:
	tower = tower_scene.instantiate()
	tower.position = tower_origin.position
	add_child(tower)
	tower.build(nb_stacks)
	is_game_over = false
	__connect_brick_dropped()
	

## Connect the brick drop signal to update the current player.
func __connect_brick_dropped() -> void:
	for brick: Brick in get_tree().get_nodes_in_group("bricks"):
		brick.dropped.connect(_on_brick_dropped)
	
	
func __build_players() -> void:
	for index in range(nb_players):
		var player = player_scene.instantiate()
		match index:
			0:
				player.variant = Player.PlayerVariantType.BOY
			1:
				player.variant = Player.PlayerVariantType.ZOMBIE
			2:
				player.variant = Player.PlayerVariantType.GIRL
			3:
				player.variant = Player.PlayerVariantType.MONSTER
				
		player.position = players_origins[index].position
		add_child(player)
		players.append(player)


func __unfreeze_tower() -> void:
	get_tree().set_group("bricks", "freeze", false)


## Indicate who is the winner
func __get_winner_index() -> StringName:
	var player_causing_game_over = current_player
	var winner_name = &"Boy"
	var max_score = -1
	for index in range(len(information_screen.players_score)):
		if index == player_causing_game_over: continue
		var score = int(information_screen.players_score[index].text)
		if max_score < score:
			max_score = score
			winner_name = players[index].sprite.animation
	return winner_name


## Update the player and the score when the Brick dropped signal is received.
func _on_brick_dropped(is_in_tower: bool) -> void:
	if not is_in_tower:
		information_screen.update_player_score(current_player)
		__set_current_player(current_player + 1)
		
