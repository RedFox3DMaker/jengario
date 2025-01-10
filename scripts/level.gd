extends Node2D


class_name Level


signal game_over


var tower_falling_played = false
var tower: Tower = null


@export var tower_scene: PackedScene


@onready var tower_origin: Marker2D = $TowerOrigin


func build_tower(nb_stacks: int) -> void:
	self.tower = tower_scene.instantiate()
	self.tower.position = self.tower_origin.position
	self.add_child(self.tower)
	self.tower.build(nb_stacks)
	self.tower_falling_played = false


func unfreeze_tower() -> void:
	get_tree().set_group("bricks", "freeze", false)


func _physics_process(_delta: float) -> void:
	if self.tower and self.tower.is_collasping() and not self.tower_falling_played:
		self.tower_falling_played = true
		AudioManager.play("res://assets/sounds/tower falling.mp3")
		self.game_over.emit()
