extends Area2D


class_name Player


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_label: Label = $PlayerLabel
@onready var player_indicator: TextureRect = $PlayerIndicator


enum PlayerVariantType { BOY, ZOMBIE, GIRL, MONSTER }
@export var variant: PlayerVariantType


signal update_score(player: Player)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var anim: StringName
	var label: String
	var color_tone: Color
	var flip: bool = false
	match variant:
		PlayerVariantType.BOY:
			anim = &"Boy"
			label = "1P"
			player_indicator.texture.region = Rect2(0, 0, 292, 248)
			color_tone = Color.CRIMSON
		PlayerVariantType.ZOMBIE:
			anim = &"Zombie"
			label = "2P"
			player_indicator.texture.region = Rect2(662, 0, 293, 248)
			color_tone = Color.LIME_GREEN
		PlayerVariantType.GIRL:
			anim = &"Girl"
			label = "3P"
			player_indicator.texture.region = Rect2(331, 0, 293, 248)
			color_tone = Color.DARK_ORANGE
			flip = true
		PlayerVariantType.MONSTER:
			anim = &"Monster"
			label = "4P"
			player_indicator.texture.region = Rect2(994, 0, 292, 248)
			color_tone = Color.REBECCA_PURPLE
			flip = true
			sprite.scale = 0.4 * Vector2.ONE

	sprite.animation = anim
	sprite.flip_h = flip
	player_label.text = label
	player_label.label_settings.font_color = color_tone

	# start the animation
	sprite.play()


func _on_body_entered(body: Node2D) -> void:
	var brick = body as Brick
	if brick and brick.held:
		brick.queue_free()
		update_score.emit(self)
