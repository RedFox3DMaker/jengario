extends Control


class_name HUD


@onready var start_screen: StartScreen = $StartScreen
@onready var end_screen: EndScreen = $EndScreen
@onready var information_screen: InformationScreen = $InformationScreen
@onready var buttons_controls: ButtonsControls = $ButtonsControls


func show_start_screen() -> void:
	self.start_screen.show()
	self.end_screen.hide()
	self.buttons_controls.show()
	self.information_screen.hide()


func show_game_screen() -> void:
	self.start_screen.hide()
	self.end_screen.hide()
	self.information_screen.show()
	self.buttons_controls.hide()

	# start vfx
	self.end_screen.stop_animations()


func show_end_screen(winner_player: StringName) -> void:
	self.start_screen.hide()
	self.end_screen.show()
	self.buttons_controls.show()
	self.information_screen.hide()

	self.end_screen.set_winner(winner_player)

	# start vfx
	self.end_screen.start_animations()


func get_winner_index() -> int:
# indication who is the winner
	var winner_index = 0
	var max_score = 0
	for index in range(len(self.information_screen.players_score)):
		var score = int(self.information_screen.players_score[index].text)
		if max_score < score:
			max_score = score
			winner_index = index
	return winner_index
