extends Control

class_name InformationScreen


@onready var player_number: Label = $MarginContainer/PlayerInfo/PlayerNumber


func set_player(number: int) -> void:
	player_number.text = str(number)
