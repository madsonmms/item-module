class_name CarryComponent
extends Node

signal item_picked_up(item: BaseItem)
signal item_dropped(item: BaseItem)

@export var pick_up_area : Area2D

var carried_item: BaseItem = null
var is_carrying: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if pick_up_area:
		pick_up_area.area_entered.connect(_on_item_nearby)
		pick_up_area.area_exited.connect(_on_item_far)
	
	pass # Replace with function body.


func picked_up_item(item: BaseItem) -> bool:
	
	if is_carrying:
		print_debug("Já está carregando um item!")
		return false
	
	if not item.is_pickable:
		print_debug("Este item não pode ser pego!")
		return false
		
	carried_item = item
	is_carrying = true
	
	item.on_picked_up(get_parent())
	
	item_picked_up.emit(item)
	
	print_debug("Carry Component reconhece o item: ", carried_item.item_name)
	return true

func drop_item() -> bool:
	
	if not is_carrying:
		print_debug("Não está carregando nada!")
		return false
		
	carried_item.on_dropped()
	
	print_debug(carried_item.item_name, " largado!")
	
	item_dropped.emit(carried_item)
	
	carried_item = null
	is_carrying = false
	
	
	return true

func _on_item_nearby(body: Node) -> void:
	if body is BaseItem and body.is_pickable:
		print_debug("Item próximo: ", body.item_name)
	pass
	
func _on_item_far(body: Node) -> void:
	if body is BaseItem:
		print_debug("Item afastou: ", body.item_name)
	pass
	
