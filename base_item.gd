class_name BaseItem
extends Area2D


@export var item_name : String

@export_group("Interaction Configuration")
enum ItemType {CARRY, PICKUP, INTERACT}
@export var item_type: ItemType = ItemType.INTERACT
@export var can_interact: bool = true
@export var interaction_label: Label #Para debug

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	pass # Replace with function body.
	
func get_item_type() -> ItemType:
	return item_type

func _on_area_entered(interaction_component: Node) -> void:
	var body = interaction_component.get_parent()
	if body.is_in_group("Player") and can_interact:
		_show_interaction_label()
	pass

func _on_area_exited(interaction_component: Node) -> void:
	var body = interaction_component.get_parent()
	if body.is_in_group("Player") and can_interact:
		_hide_interaction_label()
	pass

func on_carry(_carrier: CharacterBody2D) -> void:
	pass

func on_dropped() -> void:
	pass

func _show_interaction_label() -> void:
	print_debug(interaction_label)
	if interaction_label:
		interaction_label.visible = true
		
		var tween = create_tween()
		tween.tween_property(interaction_label, "scale", Vector2(1,1), 0.2)\
		.from(Vector2(0.5,0.5))

func _hide_interaction_label() -> void:
	if interaction_label:
		interaction_label.visible = false
