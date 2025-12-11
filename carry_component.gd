class_name CarryComponent
extends Area2D

signal item_picked_up(item: BaseItem)
signal item_dropped(item: BaseItem)
signal item_found(item: BaseItem)
signal item_lost(item: BaseItem)

var carried_item: BaseItem = null
var is_carrying: bool = false
var available_item: BaseItem = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	area_entered.connect(_on_item_nearby)
	area_exited.connect(_on_item_far)
	
	pass # Replace with function body.
	
func try_interact() -> bool:
	print_debug("Tentando interagir...")
	
	if is_carrying:
		return drop_item()
	elif available_item:
		return try_carry(available_item)
	else:
		print_debug("Nenhum item próximo para interagir")
		return false

func try_carry(item: BaseItem) -> bool:
	
	var types_list = BaseItem.ItemType
	var item_type = item.get_item_type()
	
	if is_carrying:
		print_debug("Já está carregando um item!")
		print_debug("Item será dropado")
		return drop_item()
	
	if item_type != types_list.CARRY || item.can_interact == false:
		print_debug("Este item não pode ser pego!")
		return false
		
	carried_item = item
	is_carrying = true
	
	item.on_carry(get_parent())
	
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

func _on_item_nearby(item: Area2D) -> void:
	
	print_debug(item.item_name)
	
	if item is BaseItem and item.can_interact and item.get_item_type() == BaseItem.ItemType.CARRY:
		available_item = item
		item_found.emit(item)
		print_debug("Item disponível para carregar: ", item.item_name)
	
func _on_item_far(item: Area2D) -> void:
	
	if item and item == available_item:
		item_lost.emit(item)
		available_item = null
		print_debug("Item fora do alcance!: ", item.item_name)
	
	pass
	
