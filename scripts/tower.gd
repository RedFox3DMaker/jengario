extends Node2D


class_name Tower


var held_brick: Brick = null
var nb_stacks: int = 6
var _start_with_squares = true


@export var brick_scene: PackedScene


func build(nb_stacks_required: int) -> void:
	"""
	Builds the tower. Create an alternation of square and rectangle blocks.
	Holds them in stacks.
	"""
	self.nb_stacks = nb_stacks_required
	# remove old blocks
	for old_brick: Brick in get_tree().get_nodes_in_group("bricks"):
		old_brick.remove_from_group("brick")
		old_brick.queue_free()

	# create the new tower
	var create_squares = self._start_with_squares
	var elevation = Vector2.ZERO
	for idx in range(self.nb_stacks):
		if create_squares:
			elevation = create_squares_level(idx, elevation)
			create_squares = false
		else:
			elevation = create_rectangle_level(idx, elevation)
			create_squares = true


func connect_brick_callbacks(brick_node: Brick) -> void:
	brick_node.clicked.connect(self._on_brick_clicked)


# create a level with 3 square brick
# return the new elevation of the tower
func create_squares_level(level_index: int, elevation: Vector2) -> Vector2:
	# instantiate the bricks
	var brick_1: Brick = self.brick_scene.instantiate()
	var brick_2: Brick = self.brick_scene.instantiate()
	var brick_3: Brick = self.brick_scene.instantiate()

	# choose the variants
	brick_1.variant = Brick.BrickVariantType.SQUARE_DOT
	brick_2.variant = Brick.BrickVariantType.SQUARE
	brick_3.variant = Brick.BrickVariantType.SQUARE_DOT

	# append to the parent scene
	self.get_parent().add_child(brick_1)
	self.get_parent().add_child(brick_2)
	self.get_parent().add_child(brick_3)

	# set the positions
	var brick_1_size_x = brick_1.get_size().x
	var brick_2_size_x = brick_2.get_size().x
	brick_1.position = self.position + elevation
	brick_2.position = self.position + elevation + Vector2.RIGHT * brick_1_size_x
	brick_3.position = self.position + elevation + Vector2.RIGHT * (brick_1_size_x + brick_2_size_x)

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
	var brick_rect: Brick = self.brick_scene.instantiate()

	# choose the variants
	brick_rect.variant = Brick.BrickVariantType.RECTANGLE

	# append to the scene
	self.get_parent().add_child(brick_rect)

	# set the positions (add correction 1/3 of the brick length to be centered)
	brick_rect.position = self.position + elevation + Vector2.RIGHT * brick_rect.get_size().x / 3

	# associate them to the group level
	brick_rect.add_to_group("level" + str(level_index))

	# connect to callbacks
	connect_brick_callbacks(brick_rect)

	return elevation + Vector2.UP * brick_rect.get_size().y


func _on_brick_clicked(brick: Brick) -> void:
	if !held_brick:
		brick.pickup()
		held_brick = brick


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(self.held_brick) and !event.pressed:
			self.held_brick.drop()
			self.held_brick = null


func compute_tower_level_rect(level: int) -> Rect2:
	var level_rect: Rect2 = Rect2()
	var level_bricks = get_tree().get_nodes_in_group("level" + str(level))
	for brick: Brick in level_bricks:
		# do not take into account the brick currently manipulated
		#if brick.held: continue
		if level_rect.position != Vector2.ZERO:
			level_rect = level_rect.merge(brick.get_rect())
		else:
			level_rect = brick.get_rect()

	return level_rect


func is_collasping() -> bool:
	"""
	Check the state of the tower.
	Start top level, compute the bounding box center of the level
	Get the level below, compute the x lowest and highest coordinates
	of all the bouding boxes.
	If the center x coordinate is not between them, the tower is collapsing
	"""
	var collapsing = false
	# from top level to down
	var levels_centers: Array[float] = []
	for idx in range(nb_stacks-1, 0, -1):
		# compute the bounding box of the level
		var level_rect: Rect2 = compute_tower_level_rect(idx)
		# check the bounding box is valid, else continue
		# empty level is still valid
		if level_rect.size == Vector2.ZERO:
			continue

		# get the bbox center (needs to be accumulated with previous levels)
		levels_centers.push_back(level_rect.get_center().x)

		# get the level below
		var level_below_rect: Rect2 = compute_tower_level_rect(idx - 1)

		# check bounding box validity
		# empty level: should continue and check the one below
		if level_below_rect.size == Vector2.ZERO:
			continue

		# get the top left, bottom right x coordinates:
		var level_below_x_left = level_below_rect.position.x
		var level_below_x_right = level_below_rect.end.x

		# compute the mean of all the centers
		var center_x = 0.
		for center in levels_centers:
			center_x += center
		center_x /= levels_centers.size()

		if level_below_x_left > center_x  or center_x > level_below_x_right:
			print("collapsing")
			collapsing = true
			break

	return collapsing


func remove_bricks() -> void:
	var bricks = get_tree().get_nodes_in_group("bricks")
	for brick in bricks:
		for group in brick.get_groups():
			brick.remove_from_group(group)
		brick.queue_free()
