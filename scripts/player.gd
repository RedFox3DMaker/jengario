extends Area2D


enum PlayerVariantType { BOY, ZOMBIE, GIRL, MONSTER }
@export var variant: PlayerVariantType


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var frame: int
	var label: String
	#var cursor: Resource
	var color_tone: Color
	var flip: bool = false
	match variant:
		PlayerVariantType.BOY:
			frame = 0
			label = "1P"
			#cursor = load("res://assets/ux/cursor_1.png")
			color_tone = Color.CRIMSON
		PlayerVariantType.ZOMBIE:
			frame = 6
			label = "2P"
			#cursor = load("res://assets/ux/cursor_2.png")
			color_tone = Color.LIME_GREEN
		PlayerVariantType.GIRL:
			frame = 11
			label = "3P"
			#cursor = load("res://assets/ux/cursor_2.png")
			color_tone = Color.DARK_ORANGE
			flip = true
		PlayerVariantType.MONSTER:
			frame = 17
			label = "4P"
			#cursor = load("res://assets/ux/cursor_2.png")
			color_tone = Color.REBECCA_PURPLE
			flip = true
		
	$Sprite2D.frame = frame
	$Sprite2D.flip_h = flip
	$PlayerLabel.text = label
	$PlayerLabel.label_settings.font_color = color_tone


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
