extends GutTest

## TestTower script.
## 
## Test the tower collapsing detection.

var tower: Tower = null
var tower_scene: PackedScene = load("res://scenes/tower.tscn")


func before_each():
	tower = tower_scene.instantiate()
	add_child(tower)


func after_each():
	# clean the bricks in the sceen
	tower.remove_bricks()
	
	# clean the tower
	tower.free()


## Only squared bricks.
## [.][ ][.]
func test_one_level_only_squares():
	tower.build(1)
	assert_false(tower.is_collasping())


## Only rectangle brick.
## [       ]
func test_one_level_only_rectangle():
	tower._start_with_squares = false
	tower.build(1)
	assert_false(tower.is_collasping())


## Two levels with all bricks, squares first.
## [       ]
## [.][ ][.]
func test_two_levels_complete_squares_first():
	tower.build(2)
	assert_false(tower.is_collasping())


## Two levels with all bricks, rectangle first.
## [.][ ][.]
## [       ]
func test_two_levels_complete_rectangle_first():
	tower._start_with_squares = false
	tower.build(2)
	assert_false(tower.is_collasping())


## Two levels with missing bricks.
## [       ]
##    [ ]
func test_two_levels_incomplete_middle_square_only():
	tower.build(2)

	# get the first level bricks
	var bricks = get_tree().get_nodes_in_group("level0")
	assert_eq(bricks.size(), 3)

	# remove the two bricks on the left and right (dotted)
	for brick: Brick in bricks:
		if brick.variant == Brick.BrickVariantType.SQUARE_DOT:
			brick.remove_from_group("level0")
	assert_false(tower.is_collasping())


## Two levels with missing bricks.
## [       ]
## [.]   [.]
func test_two_levels_incomplete_middle_square_missing():
	tower.build(2)

	# get the first level bricks
	var bricks = get_tree().get_nodes_in_group("level0")
	assert_eq(bricks.size(), 3)

	# remove the middle brick
	for brick: Brick in bricks:
		if brick.variant == Brick.BrickVariantType.SQUARE:
			brick.remove_from_group("level0")
	assert_false(tower.is_collasping())


## Two levels with missing bricks.
## [       ]
## [.]
func test_two_levels_incomplete_first_square_only():
	tower.build(2)

	# get the first level bricks
	var bricks = get_tree().get_nodes_in_group("level0")
	assert_eq(bricks.size(), 3)

	# remove the middle brick and one of the dotted brick
	var removed_bricks_types: Array[Brick.BrickVariantType] = []
	for brick: Brick in bricks:
		if brick.variant in removed_bricks_types:
			continue

		brick.remove_from_group("level0")
		removed_bricks_types.append(brick.variant)

		if removed_bricks_types.size() == 2:
			break

	assert_true(tower.is_collasping())


## Three levels with the middle missing, starting with rectangle.
## 		 [.]
## [       ]
func test_two_levels_rectangle_first_brick_hanging_no_contact():
	tower._start_with_squares = false
	tower.build(2)

	# get the bricks
	var bricks = get_tree().get_nodes_in_group("level1")
	assert_eq(bricks.size(), 3)

	# remove the first two, then push the last so it is hanging
	for brick: Brick in bricks.slice(0, 2):
		brick.remove_from_group("level1")
		brick.free()
		
	# check the group
	bricks = get_tree().get_nodes_in_group("level1")
	assert_eq(bricks.size(), 1)

	var hanging_brick: Brick = bricks[0]
	var brick_width = hanging_brick.sprite.region_rect.size.x
	hanging_brick.position += Vector2.RIGHT * brick_width
	assert_true(tower.is_collasping())

	# change the brick status to held
	hanging_brick.clicked.emit(hanging_brick)
	await wait_for_signal(hanging_brick.clicked, 0.5)
	assert_false(tower.is_collasping())


## Three levels with the middle missing, starting with rectangle.
##	  [ ][.]
## [       ]
func test_two_levels_rectangle_first_brick_hanging_contact():
	tower._start_with_squares = false
	tower.build(2)

	# get the bricks
	var bricks = get_tree().get_nodes_in_group("level1")
	assert_eq(bricks.size(), 3)

	# remove the first two, then push the last so it is hanging
	bricks[0].remove_from_group("level1")
	bricks[0].free()
	
	bricks = get_tree().get_nodes_in_group("level1")
	assert_eq(bricks.size(), 2)
	
	# move the bricks to the right, starting with the rightmost brick
	bricks.reverse()
	for brick: Brick in bricks:
		brick.position += Vector2.RIGHT * brick.get_size().x
	bricks.reverse()

	assert_true(tower.is_collasping())

	# simulate a click on the brick
	var hanging_brick = bricks[1]
	hanging_brick.clicked.emit(hanging_brick)
	await wait_for_signal(hanging_brick.clicked, 0.1)
	
	assert_false(tower.is_collasping())


## Three levels with the middle missing, starting with rectangle.
## [.][ ][.]
##
## [.][ ][.]
func test_three_levels_level1_missing_squares_first():
	tower.build(3)

	# get the middle level bricks
	var bricks = get_tree().get_nodes_in_group("level1")
	assert_eq(bricks.size(), 1)

	# remove all the bricks
	for brick: Brick in bricks:
		brick.remove_from_group("level1")

	# the tower should not collapse
	assert_false(tower.is_collasping())


## Three levels with the middle missing, starting with rectangle.
## [       ]
## 
## [       ]
func test_three_levels_level1_missing_rectangle_first():
	tower._start_with_squares = false
	tower.build(3)

	# get the middle level bricks
	var bricks = get_tree().get_nodes_in_group("level1")
	assert_eq(bricks.size(), 3)

	# remove all the bricks
	for brick: Brick in bricks:
		brick.remove_from_group("level1")

	# the tower should not collapse
	assert_false(tower.is_collasping())
