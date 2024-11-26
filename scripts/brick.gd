class_name Brick


extends RigidBody2D


signal clicked
signal fallen

enum BrickVariantType { SQUARE_DOT, SQUARE, RECTANGLE }
@export var variant: BrickVariantType

class BrickVariant:
	var region: Vector2
	var size: Vector2

	func init(i_region: Vector2, i_size: Vector2) -> BrickVariant:
		self.region = i_region
		self.size = i_size
		return self

var variant_dict = {
	BrickVariantType.SQUARE_DOT: BrickVariant.new().init(Vector2(9, 13), Vector2(47,46)),
	BrickVariantType.SQUARE: BrickVariant.new().init(Vector2(68,13), Vector2(47,46)),
	BrickVariantType.RECTANGLE: BrickVariant.new().init(Vector2(9,61), Vector2(139,40)),
}

func _ready() -> void:
	freeze = true
	var brick_variant = variant_dict[variant]
	$Sprite2D.region_rect = Rect2(brick_variant.region, brick_variant.size)
	$CollisionShape2D.shape.size = brick_variant.size
	freeze = false


var held = false
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			AudioManager.play("res://assets/sounds/click sfx.mp3")
			clicked.emit(self)


const MAX_VELOCITY: float = 50.0
const MAX_APPLIED_FORCE: float = 250.0
var previous_velocity: Vector2 = Vector2.ZERO
var sound_played = false
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if held:
		# normalize the direction of the mouse pointer
		# and compute velocity to apply force
		var motion = get_global_mouse_position() - global_transform.origin
		var delta = state.step;
		var velocity = motion / state.step
		var velocity_norm = 0.01 * velocity.length()
		if velocity_norm >= MAX_VELOCITY:
			velocity *= MAX_VELOCITY / velocity_norm

		var applied_force = mass * (velocity - previous_velocity) / delta
		previous_velocity = velocity
		var applied_force_norm = applied_force.length()
		if applied_force_norm >= MAX_APPLIED_FORCE:
			applied_force *= MAX_APPLIED_FORCE / applied_force_norm
		state.apply_force(applied_force)
		
		if not sound_played:
			AudioManager.play("res://assets/sounds/dragging stone sound eff.mp3")
		sound_played = true

var previous_velocity_y = 980.0
const GRAVITY_Y: float = 980.0
const THETA_FALL: float = deg_to_rad(5)
func _physics_process(delta: float) -> void:
	if not held and is_in_group("bricks"):
		var acceleration_y = (linear_velocity.y - previous_velocity_y) / delta
		previous_velocity_y = linear_velocity.y
		if acceleration_y >= 0.5 * GRAVITY_Y and rotation >= THETA_FALL:
			print("fallen")
			fallen.emit()

func pickup() -> void:
	if held:
		return
	sleeping = false
	held = true
	previous_velocity_y = 0.0

func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if held:
		apply_central_impulse(impulse)
		previous_velocity = Vector2.ZERO
		held = false
		if get_contact_count() == 0:
			remove_from_group("bricks")
	else:
		sound_played = false
