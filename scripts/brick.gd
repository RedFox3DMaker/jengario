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


const MAX_VELOCITY: float = 50.0
const MAX_APPLIED_FORCE: float = 250.0
var previous_velocity: Vector2 = Vector2.ZERO
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if held:
		# normalize the direction of the mouse pointer 
		# and compute velocity to apply force
		var mouse_pos = get_global_mouse_position()
		var motion = get_global_mouse_position() - global_transform.origin
		var delta = state.step;
		var velocity = motion / state.step
		var velocity_norm = 0.01 * velocity.length()
		print("velocity_norm: ", velocity_norm)
		if velocity_norm >= MAX_VELOCITY:
			velocity *= MAX_VELOCITY / velocity_norm
		
		var applied_force = mass * (velocity - previous_velocity) / delta
		previous_velocity = velocity
		var applied_force_norm = applied_force.length()
		if applied_force_norm >= MAX_APPLIED_FORCE:
			applied_force *= MAX_APPLIED_FORCE / applied_force_norm
		print("applied_force: ", applied_force)
		state.apply_force(applied_force)


func pickup() -> void:
	if held:
		return
	#freeze = true
	sleeping = false
	held = true


func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if held:
		#freeze = false
		apply_central_impulse(impulse)
		previous_velocity = Vector2.ZERO
		held = false
