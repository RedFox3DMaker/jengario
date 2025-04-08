class_name Screens
extends Control

## Screens script
##
## Manages start, pause and end screens.

@onready var start_screen: StartScreen = $StartScreen
@onready var end_screen: EndScreen = $EndScreen

func show_start_screen() -> void:
	start_screen.show()
	end_screen.hide()
	end_screen.stop_animations()
	

func hide_end_screen() -> void:
	end_screen.hide()
	end_screen.stop_animations()


func show_end_screen(winner_player: StringName, nb_players) -> void:
	start_screen.hide()
	end_screen.show()
	
	end_screen.set_winner(winner_player, nb_players)
	
	# create a smooth transition to the end screen
	end_screen.modulate.a = 0
	var tween = create_tween()
	var tween_modulate = tween.tween_property(end_screen, "modulate:a", 1, 1)
	await tween_modulate.finished

	# start vfx
	end_screen.start_animations()
