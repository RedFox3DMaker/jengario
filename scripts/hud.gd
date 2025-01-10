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


func show_end_screen() -> void:
	self.start_screen.hide()
	self.end_screen.show()
	self.buttons_controls.show()
	self.information_screen.hide()
	

func get_buttons_controls() -> ButtonsControls:
	return self.buttons_controls
	
	
func get_information_screen() -> InformationScreen:
	return self.information_screen
