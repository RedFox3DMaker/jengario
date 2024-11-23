extends Node2D


var held_object: Brick = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("bricks"):
		node.clicked.connect(_on_pickable_clicked)


func _on_pickable_clicked(object) -> void:
	if !held_object:
		object.pickup()
		held_object = object


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop()#0.0001*Input.get_last_mouse_velocity())
			held_object = null
