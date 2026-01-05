extends Item
class_name Caixa

var active : bool = false

@onready var rigid_body : RigidBody2D = $"."
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	_update_visual_state()

func _on_interaction_started(_interactor: CharacterBody2D) -> void:
	print_debug("Caixa: interação iniciada...")
	
	active = not active
	
	_update_visual_state()

func _on_carry_started(_carrier: CharacterBody2D) -> void:
	
	rigid_body.freeze = false
	rigid_body.gravity_scale = 0
	rigid_body.linear_velocity = Vector2.ZERO
	rigid_body.angular_velocity = 0
	
	if collision_shape:
		collision_shape.disabled = true
	
	pass

func _on_drop_started(_carrier: CharacterBody2D) -> void:
	rigid_body.freeze = false
	rigid_body.gravity_scale = 0
	rigid_body.linear_velocity = Vector2.ZERO
	rigid_body.angular_velocity = 0
	
	if collision_shape:
		collision_shape.disabled = false

func _update_visual_state() -> void:
	if sprite:
		sprite.modulate = Color.GREEN if active else Color.WHITE
		
