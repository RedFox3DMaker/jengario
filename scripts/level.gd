extends Node2D


class_name Level


signal game_over


var tower_falling_played = false
var tower: Tower = null
var players: Array[Player] = []


@export var tower_scene: PackedScene
@export var player_scene: PackedScene


@onready var players_origins: Array[Marker2D] = [
	$"PlayersOrigins/Player1Origin",
	$"PlayersOrigins/Player2Origin",
	$"PlayersOrigins/Player3Origin",
	$"PlayersOrigins/Player4Origin"
]
@onready var tower_origin: Marker2D = $TowerOrigin


func build_tower(nb_stacks: int) -> void:
	self.tower = tower_scene.instantiate()
	self.tower.position = self.tower_origin.position
	self.add_child(self.tower)
	self.tower.build(nb_stacks)
	self.tower_falling_played = false
	
	
func build_players(nb_players: int) -> void:
	for index in range(nb_players):
		var player = self.player_scene.instantiate()
		match index:
			0:
				player.variant = Player.PlayerVariantType.BOY
			1:
				player.variant = Player.PlayerVariantType.ZOMBIE
			2:
				player.variant = Player.PlayerVariantType.GIRL
			3:
				player.variant = Player.PlayerVariantType.MONSTER
				
		player.position = self.players_origins[index].position
		self.add_child(player)
		self.players.append(player)


func unfreeze_tower() -> void:
	get_tree().set_group("bricks", "freeze", false)
	
	
func remove_players() -> void:
	for player in self.players:
		player.queue_free()
	self.players.clear()


func _physics_process(_delta: float) -> void:
	if self.tower and self.tower.is_collasping() and not self.tower_falling_played:
		self.tower_falling_played = true
		AudioManager.play("res://assets/sounds/tower falling.mp3")
		self.game_over.emit()
