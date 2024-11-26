extends Node2D


signal game_over


var held_object: Brick = null
var tower_falling_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("bricks"):
		node.clicked.connect(_on_brick_clicked)
		node.fallen.connect(_on_brick_fallen)


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
