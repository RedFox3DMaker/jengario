class_name EndScreen
extends Control

## EndScreen script
## 
## Show the winner and the loosers and propose to restart the game.

@onready var confetti: GPUParticles2D = $ConfettiParticles
@onready var rain: GPUParticles2D = $RainParticles
@onready var winner_player: AnimatedSprite2D = $"WinnerPlayer"
@onready var looser_players: Array[AnimatedSprite2D] = [
	$"LooserPlayer1",
	$"LooserPlayer2",
	$"LooserPlayer3"
]


func start_animations() -> void:
	confetti.emitting = true
	rain.emitting = true


func stop_animations() -> void:
	confetti.emitting = false
	rain.emitting = false


func set_winner(winner: StringName, nb_players: int) -> void:
	var loosers: Array[StringName] = [&"Boy", &"Zombie", &"Girl", &"Monster"]
	loosers.erase(winner)

	winner_player.animation = winner

	for index in range(len(loosers)):
		var looser_anim = loosers[index]
		var looser_player = looser_players[index]
		looser_player.animation = looser_anim
		looser_player.visible = index < nb_players - 1
