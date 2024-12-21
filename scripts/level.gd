extends Node2D


signal game_over


var held_object: Brick = null
var tower_falling_played = false


@onready var brick_origin: Marker2D = $BrickOrigin


@export var nb_stacks: int = 6
@export var brick_scene: PackedScene


func connect_brick_callbacks(brick_node: Brick) -> void:
	brick_node.clicked.connect(_on_brick_clicked)
	#brick_node.fallen.connect(_on_brick_fallen)


# create a level with 3 square brick
# return the new elevation of the tower
func create_squares_level(level_index: int, elevation: Vector2) -> Vector2:
	# instantiate the bricks
	var brick_1: Brick = brick_scene.instantiate()
	var brick_2: Brick = brick_scene.instantiate()
	var brick_3: Brick = brick_scene.instantiate()
	
	# choose the variants
	brick_1.variant = Brick.BrickVariantType.SQUARE_DOT
	brick_2.variant = Brick.BrickVariantType.SQUARE
	brick_3.variant = Brick.BrickVariantType.SQUARE_DOT
	
	# append to the scene
	add_child(brick_1)
	add_child(brick_2)
	add_child(brick_3)
	
	# set the positions
	var brick_1_size_x = brick_1.get_size().x
	var brick_2_size_x = brick_2.get_size().x
	brick_1.position = brick_origin.position + elevation
	brick_2.position = brick_origin.position + elevation + Vector2.RIGHT * brick_1_size_x
	brick_3.position = brick_origin.position + elevation + Vector2.RIGHT * (brick_1_size_x + brick_2_size_x)
	
	# associate them to the group level
	brick_1.add_to_group("level" + str(level_index))
	brick_2.add_to_group("level" + str(level_index))
	brick_3.add_to_group("level" + str(level_index))
	
	# connect to callbacks
	connect_brick_callbacks(brick_1)
	connect_brick_callbacks(brick_2)
	connect_brick_callbacks(brick_3)
	
	return elevation + Vector2.UP * brick_1.get_size().y
	
	
# create a level with 1 rectangle brick
# return the new elevation of the tower
func create_rectangle_level(level_index: int, elevation: Vector2) -> Vector2:
	# instantiate the bricks
	var brick_rect: Brick = brick_scene.instantiate()
	
	# choose the variants
	brick_rect.variant = Brick.BrickVariantType.RECTANGLE
	
	# append to the scene
	add_child(brick_rect)
	
	# set the positions (add correction 1/3 of the brick length to be centered)
	brick_rect.position = brick_origin.position + elevation + Vector2.RIGHT * brick_rect.get_size().x / 3
	
	# associate them to the group level
	brick_rect.add_to_group("level" + str(level_index))
	
	# connect to callbacks
	connect_brick_callbacks(brick_rect)
	
	return elevation + Vector2.UP * brick_rect.get_size().y


# function to build the tower
func init_tower() -> void:
	# remove old blocks
	get_tree().call_group("bricks", &"queue_free")
	
	# create the new tower
	var elevation = Vector2.ZERO
	for idx in range(nb_stacks):
		if idx % 2 == 0:
			elevation = create_squares_level(idx, elevation)
		else:
			elevation = create_rectangle_level(idx, elevation)
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_tower()


func unfreeze_tower() -> void:
	get_tree().set_group("bricks", "freeze", false)


func _on_brick_clicked(object) -> void:
	if !held_object:
		object.pickup()
		held_object = object

func _on_brick_fallen() -> void:
	if not tower_falling_played:
		tower_falling_played = true
		AudioManager.play("res://assets/sounds/tower falling.mp3")
	game_over.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()
			held_object = null
			
			
func compute_tower_level_rect(level: int) -> Rect2:
	var level_rect: Rect2 = Rect2()
	for brick: Brick in get_tree().get_nodes_in_group("level" + str(level)):
		if level_rect.position != Vector2.ZERO:
			level_rect = level_rect.merge(brick.get_rect())
		else:
			level_rect = brick.get_rect()
	
	return level_rect
	
			
func is_tower_collasping() -> bool:
	"""
	Check the state of the tower.
	Start top level, compute the bounding box center of the level
	Get the level below, compute the x lowest and highest coordinates 
	of all the bouding boxes.
	If the center x coordinate is not between them, the tower is collapsing
	"""
	var is_collapsing = false
	var top_level_checked = false
	# from top level to down
	var levels_centers: Array[float] = []
	for idx in range(nb_stacks-1, 1, -1):
		# compute the bounding box of the level
		var level_rect: Rect2 = compute_tower_level_rect(idx)
		# check the bounding box is valid
		if level_rect.size == Vector2.ZERO:
			if not top_level_checked:
				continue
			else:
				is_collapsing = true
				break
		
		# first top level is checked
		if not top_level_checked:
			top_level_checked = true
		
		# get the level below
		var level_below_rect: Rect2 = compute_tower_level_rect(idx - 1)
		
		# check bounding box validity
		if level_below_rect.size == Vector2.ZERO:
			is_collapsing = true
			break
		
		# get the bbox center (needs to be accumulated with previous levels)
		levels_centers.push_back(level_rect.get_center().x)
		var center_x = 0.
		for center in levels_centers:
			center_x += center
		center_x /= levels_centers.size()
		
		# get the top left, bottom right x coordinates:
		var level_below_x_left = level_below_rect.position.x
		var level_below_x_right = level_below_rect.end.x
		
		if level_below_x_left > center_x  or center_x > level_below_x_right:
			print("is_collapsing")
			is_collapsing = true
			break
		
	return is_collapsing
	

func _physics_process(_delta: float) -> void:
	if is_tower_collasping() and not tower_falling_played:
		tower_falling_played = true
		AudioManager.play("res://assets/sounds/tower falling.mp3")
		game_over.emit()
