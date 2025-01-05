class_name Brick


extends RigidBody2D


signal clicked
signal dropped


@onready var explosion_animation: AnimatedSprite2D = $ExplosionAnimation
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


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
	sprite.region_rect = Rect2(brick_variant.region, brick_variant.size)
	collision_shape.shape.size = brick_variant.size
	if variant == BrickVariantType.RECTANGLE:
		explosion_animation.animation = &"rectangle_explosion"
	else:
		explosion_animation.animation = &"square_explosion"


var held = false
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			AudioManager.play("res://assets/sounds/click sfx.mp3")
			self.clicked.emit(self)


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


func _physics_process(delta: float) -> void:
	if not is_in_group("bricks") and not self.held: 
		explosion_animation.visible = true
		sprite.visible = false
		explosion_animation.play()
	elif self.held:
		# check if there is a brick above...
		const TEST_SPEED = 10
		var is_contact_up = self.test_move(self.transform, Vector2.UP * delta * TEST_SPEED)
		var is_contact_down = false
		
		# ... or below, except on the floor
		if not is_in_group("level0"):
			is_contact_down = self.test_move(self.transform, Vector2.DOWN * delta * TEST_SPEED)
		
		# if there is no contact then remove from all groups
		if not is_contact_up and not is_contact_down:
			for group in get_groups():
				remove_from_group(group)


func pickup() -> void:
	if held:
		return
	sleeping = false
	held = true
	#previous_velocity_y = 0.0
	lock_rotation = true


func drop(impulse: Vector2 = Vector2.ZERO) -> void:
	if held:
		apply_central_impulse(impulse)
		previous_velocity = Vector2.ZERO
		held = false
		lock_rotation = false
		self.dropped.emit()
	else:
		sound_played = false


func _on_explosion_animation_animation_finished() -> void:
	queue_free()


func get_size() -> Vector2:
	return collision_shape.shape.size


func get_rect() -> Rect2:
	var local_rect = collision_shape.shape.get_rect()
	var global_rect: Rect2 = Rect2(local_rect.position + global_position, local_rect.size)
	return global_rect
