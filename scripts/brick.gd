extends RigidBody2D

class_name Brick

signal clicked

enum BrickVariantType { TYPE_1, TYPE_2, TYPE_3 }
@export var variant: BrickVariantType;

class BrickVariant:
	var region: Vector2
	var size: Vector2
	
	func init(i_region: Vector2, i_size: Vector2) -> BrickVariant:
		self.region = i_region
		self.size = i_size
		return self

var variant_dict = {
	BrickVariantType.TYPE_1: BrickVariant.new().init(Vector2(9, 13), Vector2(47,46)),
	BrickVariantType.TYPE_2: BrickVariant.new().init(Vector2(68,13), Vector2(47,46)),
	BrickVariantType.TYPE_3: BrickVariant.new().init(Vector2(9,61), Vector2(139,40)),
}

func _ready() -> void:
	freeze = true
	var brick_variant = variant_dict[variant]
	$Sprite2D.region_rect = Rect2(brick_variant.region, brick_variant.size)
	$CollisionShape2D.shape.size = brick_variant.size
	$RayCast2DDownLeft.position.x = -brick_variant.size.x / 2
	$RayCast2DDownRight.position.x = brick_variant.size.x / 2
	freeze = false


var held = false
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)


const MAX_VELOCITY: float = 175.0
func _physics_process(delta: float) -> void:
	if held:
		var mouse_pos = get_global_mouse_position()
		var global_motion = get_global_mouse_position() - global_transform.origin
		# correction to avoid push block downward too much 
		# when in contact with other blocks
		print("global_motion: ", global_motion)
		if $RayCast2DDownLeft.is_colliding() or $RayCast2DDownRight.is_colliding() and global_motion.y >= 0:
			global_motion.y = 0
		#if $RayCast2DUp.is_colliding() and global_motion.y <= -1:
		#	global_motion.y *= 0.01
		var velocity: Vector2 = global_motion / delta
		print("velocity: ", velocity)
		var velocity_norm = sqrt(velocity.x**2 + velocity.y**2)
		if velocity_norm > MAX_VELOCITY:
			velocity *= MAX_VELOCITY / velocity_norm
		global_transform.origin += delta * velocity


func pickup() -> void:
	if held:
		return
	freeze = true
	held = true


func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
