class_name Player
extends CharacterBody2D

var move_speed: float = 100.00

@onready var interact_component = $InteractComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	velocity = move_speed * dir
	move_and_slide()
	
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		
		interact_component.try_interact()
		
	if event.is_action_pressed("ui_cancel"):  # ESC
		interact_component.drop_item()
	
	pass
	
