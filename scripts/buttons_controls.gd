class_name ButtonsControls
extends Control

## ButtonsControls script
## 
## Show the buttons to control the game

signal start_game(nb_stacks: int)
signal exit_game

var nb_stacks: int
var nb_players: int

@onready var accept_dialog: AcceptDialog = $AcceptDialog


func _ready() -> void:
	nb_stacks = $AcceptDialog/Control/GridContainer/NbTowerValue.value
	nb_players = $AcceptDialog/Control/GridContainer/NbPlayersValue.value


func _on_start_button_pressed() -> void:
	start_game.emit(nb_stacks, nb_players)
	$MarginContainer/Buttons/StartButton.text = "RESTART"


func _on_settings_button_pressed() -> void:
	accept_dialog.show()


func _on_exit_button_pressed() -> void:
	exit_game.emit()


func _on_accept_dialog_confirmed() -> void:
	nb_stacks = $AcceptDialog/Control/GridContainer/NbTowerValue.value
	nb_players = $AcceptDialog/Control/GridContainer/NbPlayersValue.value
