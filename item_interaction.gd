class_name InteractionArea
extends Area2D

@export_group("Interaction Configuration")
@export var active: bool = true
@export var interaction_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	pass

func _on_area_entered(interaction_component: Node) -> void:
	
	var body = interaction_component.get_parent()
	
	if body.is_in_group("Player") and active:
		_show_interaction_label()
	pass

func _on_area_exited(interaction_component: Node) -> void:
	var body = interaction_component.get_parent()
	if body.is_in_group("Player") and active:
		_hide_interaction_label()
	pass

func _show_interaction_label() -> void:
	
	if interaction_label:
		interaction_label.visible = true
		
		var tween = create_tween()
		tween.tween_property(interaction_label, "scale", Vector2(1,1), 0.2)\
		.from(Vector2(0.5,0.5))

func _hide_interaction_label() -> void:
	if interaction_label:
		interaction_label.visible = false

func _disable_physics() -> void:
	pass

func _enable_physics() -> void:
	pass
