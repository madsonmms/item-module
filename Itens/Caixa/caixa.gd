extends Interactable
class_name Caixa

var active : bool = false

@onready var rigid_body : RigidBody2D = $"."
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var interaction_label: Label = $InteractionLabel

func _ready() -> void:
	
	detection_start.connect(on_detection_start)
	detection_end.connect(on_detection_end)
	
	_update_visual_state()
	
func on_detection_start(_detector: Node) -> void:
	
	if interaction_label:
		interaction_label.text = "[E]"
		interaction_label.visible = true
		
func on_detection_end(_detector: Node) -> void:
		print_debug("[Caixa] detection ended")
		_hide_detection_feedback()

func _on_interaction_started(_interactor: CharacterBody2D) -> void:
	active = not active
	
	_update_visual_state()

func _on_carry_started(_carrier: CharacterBody2D) -> void:
	
	rigid_body.freeze = false
	rigid_body.gravity_scale = 0
	rigid_body.linear_velocity = Vector2.ZERO
	rigid_body.angular_velocity = 0
	
	if collision_shape:
		collision_shape.disabled = true
	
	set_interactable(false)
	
	_hide_detection_feedback()
	
	pass

func _on_drop_started(_carrier: CharacterBody2D) -> void:
	rigid_body.freeze = false
	rigid_body.gravity_scale = 0
	rigid_body.linear_velocity = Vector2.ZERO
	rigid_body.angular_velocity = 0
	
	if collision_shape:
		collision_shape.disabled = false
	
	interaction_active = true
	

func _update_visual_state() -> void:
	if sprite:
		sprite.modulate = Color.GREEN if active else Color.WHITE
		
