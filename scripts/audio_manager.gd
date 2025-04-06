extends Node

## AudioManager script
## 
## Global node to play sounds.

var num_players = 4
var bus = "master"

var available = [] # the available players
var queue = [] # the queue of sounds to play


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
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()


func play(sound_path: String):
	queue.append(sound_path)
	

## When finised playing a stream, make the player available again
func _on_stream_finished(stream: AudioStreamPlayer):
	available.append(stream)
