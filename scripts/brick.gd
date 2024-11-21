extends RigidBody2D

enum BrickVariantType { TYPE_1, TYPE_2, TYPE_3 }
@export var variant: BrickVariantType;

class BrickVariant:
	var region: Vector2
	var size: Vector2
	
	func init(region: Vector2, size: Vector2) -> BrickVariant:
		self.region = region
		self.size = size
		return self

var variant_dict = {
	BrickVariantType.TYPE_1: BrickVariant.new().init(Vector2(9, 13), Vector2(47,46)),
	BrickVariantType.TYPE_2: BrickVariant.new().init(Vector2(68,13), Vector2(47,46)),
	BrickVariantType.TYPE_3: BrickVariant.new().init(Vector2(9,61), Vector2(139,40)),
}

var dragging = false

func _ready():
	var brick_variant = variant_dict[variant]
	$Sprite2D.region_rect = Rect2(brick_variant.region, brick_variant.size)
	$CollisionShape2D.shape.size = brick_variant.size

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var sprite_size = $Sprite2D.region_rect.size
		var relative_position = abs(event.position - $Sprite2D.global_position)
		if relative_position.x < sprite_size.x and relative_position.y < sprite_size.y:
			# start dragging if the click is on the sprite
			if not dragging and event.pressed:
				dragging = true
			# stop dragging if the button is released
		if dragging and not event.pressed:
			dragging = false
			
	if event is InputEventMouseMotion and dragging:
		$Sprite2D.global_position = event.position
