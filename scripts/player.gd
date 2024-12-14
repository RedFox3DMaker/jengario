extends Area2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_label: Label = $PlayerLabel

enum PlayerVariantType { BOY, ZOMBIE, GIRL, MONSTER }
@export var variant: PlayerVariantType


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var anim: StringName
	var label: String
	#var cursor: Resource
	var color_tone: Color
	var flip: bool = false
	match variant:
		PlayerVariantType.BOY:
			anim = &"Boy"
			label = "1P"
			#cursor = load("res://assets/ux/cursor_1.png")
			color_tone = Color.CRIMSON
		PlayerVariantType.ZOMBIE:
			anim = &"Zombie"
			label = "2P"
			#cursor = load("res://assets/ux/cursor_2.png")
			color_tone = Color.LIME_GREEN
		PlayerVariantType.GIRL:
			anim = &"Girl"
			label = "3P"
			#cursor = load("res://assets/ux/cursor_2.png")
			color_tone = Color.DARK_ORANGE
			flip = true
		PlayerVariantType.MONSTER:
			anim = &"Monster"
			label = "4P"
			#cursor = load("res://assets/ux/cursor_2.png")
			color_tone = Color.REBECCA_PURPLE
			flip = true
		
	sprite.animation = anim
	sprite.flip_h = flip
	player_label.text = label
	player_label.label_settings.font_color = color_tone
	
	# start the animation
	sprite.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
