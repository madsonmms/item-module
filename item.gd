class_name Item
extends Node2D

enum ItemType {CARRY, PICKUP, INTERACT, PROP}
@export var item_type: ItemType = ItemType.INTERACT

func _ready() -> void:
	pass # Replace with function body.

func get_item_type() -> ItemType:
	return item_type

func on_carry(_actor: CharacterBody2D) -> void:
	pass

func on_interact(_actor: CharacterBody2D) -> void:
	pass

func on_pickup(_actor: CharacterBody2D) -> void:
	pass

func on_dropped() -> void:
	pass
