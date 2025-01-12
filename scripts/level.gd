extends Node2D


class_name Level


signal game_over


var tower_falling_played = false
var tower: Tower = null


@export var tower_scene: PackedScene


@onready var players: Array[Player] = [
	$"Players/Player 1",
	$"Players/Player 2",
	$"Players/Player 3",
	$"Players/Player 4"
]
@onready var tower_origin: Marker2D = $TowerOrigin


func build_tower(nb_stacks: int) -> void:
	self.tower = tower_scene.instantiate()
	self.tower.position = self.tower_origin.position
	self.add_child(self.tower)
	self.tower.build(nb_stacks)
	self.tower_falling_played = false


func unfreeze_tower() -> void:
	get_tree().set_group("bricks", "freeze", false)
	
	
func show_players(i_show: bool) -> void:
	for player in players:
		player.visible = i_show


func _physics_process(_delta: float) -> void:
	if self.tower and self.tower.is_collasping() and not self.tower_falling_played:
		self.tower_falling_played = true
		AudioManager.play("res://assets/sounds/tower falling.mp3")
		self.game_over.emit()
