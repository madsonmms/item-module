class_name Item
extends Node2D

enum ItemType {CARRY, PICKUP, INTERACT, PROP}
@export var item_type: ItemType = ItemType.INTERACT
@export var interaction_area: InteractionArea
@export var collision: CollisionShape2D

func _ready() -> void:
	pass 
	
func get_item_type() -> ItemType:
	return item_type


# PUBLIC INTERFACE - For other systems #
func notify_interaction_start(interactor: CharacterBody2D) -> void:
	_on_interaction_started(interactor)

func notify_carry_start(carrier: CharacterBody2D) -> void:
	_on_carry_started(carrier)

func notify_drop_start(carrier: CharacterBody2D) -> void:
	_on_drop_started(carrier)

# VIRTUAL METHODS - For specific items use #
func _on_interaction_started(_interactor: CharacterBody2D) -> void:
	push_warning("_on_interaction_started() não implementado em: ", name)

func _on_carry_started(_carrier: CharacterBody2D) -> void:
	push_warning("_on_carry_started() não implementado em: ", name)
	
func _on_drop_started(_carrier: CharacterBody2D) -> void:
	push_warning("_on_drop_started() não implementado em: ", name)
