extends Node

## AudioManager script
## 
## Global node to play sounds.

var num_players = 4
var bus = "master"

var available = [] # the available players
var queue = [] # the queue of sounds to play

@onready var sounds := {
	"CLICK": load("res://assets/sounds/click sfx.mp3"),
	"DRAG": load("res://assets/sounds/dragging stone sound eff.mp3"),
	"MENU": load("res://assets/sounds/menu song mdj.mp3"),
	"TOWER_FALL": load("res://assets/sounds/tower falling.mp3"),
	"GAME": load("res://assets/sounds/mdj gameplay.mp3"),
	"END": load("res://assets/sounds/Victory and ending song.mp3")
}


func _ready() -> void:
	# create the pool of AudioStreamPlayers
	for i in num_players:
		var player = AudioStreamPlayer.new()
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(player)
		available.append(player)
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus


func _process(_delta: float) -> void:
	# play a queued sound if any players are available
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = queue.pop_front()
		available[0].play()
		available.pop_front()


func play(sound_name: String):
	queue.append(sounds[sound_name])
	

## When finised playing a stream, make the player available again
func _on_stream_finished(stream: AudioStreamPlayer):
	available.append(stream)
