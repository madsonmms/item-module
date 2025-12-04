class_name CarryComponent
extends Node

signal item_picked_up(item: BaseItem)
signal item_dropped(item: BaseItem)

var carried_item: BaseItem = null
var is_carrying: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	carried_item = null
	is_carrying = false
	
	return true
	
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
