extends Control

class_name InformationScreen


@onready var players_label: Array[Label] = [
	$MarginContainer/PlayersInfo/PlayerInfoItem1/PlayerLabel,
	$MarginContainer/PlayersInfo/PlayerInfoItem2/PlayerLabel,
	$MarginContainer/PlayersInfo/PlayerInfoItem3/PlayerLabel,
	$MarginContainer/PlayersInfo/PlayerInfoItem4/PlayerLabel
]
@onready var players_score: Array[Label] = [
	$MarginContainer/PlayersInfo/PlayerInfoItem1/PlayerScore,
	$MarginContainer/PlayersInfo/PlayerInfoItem2/PlayerScore,
	$MarginContainer/PlayersInfo/PlayerInfoItem3/PlayerScore,
	$MarginContainer/PlayersInfo/PlayerInfoItem4/PlayerScore
]


func set_player(number: int) -> void:
	for index in range(len(players_label)):
		var player_label: Label = players_label[index]
		if number == index:
			player_label.label_settings.outline_size = 10
		else:
			player_label.label_settings.outline_size = 0


func update_player_score(number: int) -> void:
	var player_score: Label = players_score[number]
	var new_score = int(player_score.text) + 1
	player_score.text = str(new_score)
	
	
func reset_players_score():
	for player_score: Label in players_score:
		player_score.text = str(0)