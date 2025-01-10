extends Control


class_name ButtonsControls


var nb_stacks: int
var nb_players: int


@onready var accept_dialog: AcceptDialog = $AcceptDialog


signal start_game(nb_stacks: int)
signal exit_game


func _ready() -> void:
	self.nb_stacks = $AcceptDialog/Control/GridContainer/NbTowerValue.value
	self.nb_players = $AcceptDialog/Control/GridContainer/NbPlayersValue.value


func _on_start_button_pressed() -> void:
	self.start_game.emit(self.nb_stacks)
	$MarginContainer/Buttons/StartButton.text = "RESTART"


func _on_settings_button_pressed() -> void:
	self.accept_dialog.show()


func _on_exit_button_pressed() -> void:
	self.exit_game.emit()


func _on_accept_dialog_confirmed() -> void:
	self.nb_stacks = $AcceptDialog/Control/GridContainer/NbTowerValue.value
	self.nb_players = $AcceptDialog/Control/GridContainer/NbPlayersValue.value
