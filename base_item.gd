class_name BaseItem
extends Node2D


@export var item_name : String

@export_group("Settings")
@export var is_pickable : bool
@export var is_collectable : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_picked_up(_carrier: CharacterBody2D) -> void:
	print_debug(item_name, " executando função de ser pego...")
	pass

func on_dropped() -> void:
	print_debug(item_name, " executando função de drop...")
