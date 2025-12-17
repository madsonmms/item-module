class_name BaseItem
extends Area2D


@export var item_name : String

@export_group("Settings")
enum ItemType {CARRY, PICKUP}
@export var item_type: ItemType = ItemType.CARRY
@export var can_interact: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	pass # Replace with function body.
	
func get_item_type() -> ItemType:
	return item_type

func _on_area_entered(body: Node) -> void:
	pass

func _on_area_exited(body: Node) -> void:
	pass

func on_carry(_carrier: CharacterBody2D) -> void:
	pass

func on_dropped() -> void:
	pass
