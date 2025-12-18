class_name InteractComponent
extends Area2D

#Sinais para uso futuro para animações, sons, etc...
signal item_interaction(item: Item)
#signal item_carring(item: Item)
#signal item_dropped(item: ItemInteraction)
#signal item_found(item: ItemInteraction)
#signal item_lost(item: ItemInteraction)

var available_item: Item = null
var carried_item: Item = null
var is_carrying: bool = false
var carry_offset: Vector2 = Vector2(0, -40)

var actor: CharacterBody2D

#Guarda o status original do item para resturar/referenciar
var carried_item_original_parent: Node = null
var carried_item_original_transform: Transform2D = Transform2D()

func _ready() -> void:
	
	area_entered.connect(_on_item_nearby)
	area_exited.connect(_on_item_far)
	
	pass

func _process(_delta: float) -> void:
	if is_carrying and carried_item:
		_update_carried_item_position()
	pass

func try_interact() -> bool:
	
	if not available_item:
		return false
		
	match available_item.get_item_type():
		available_item.ItemType.CARRY:
			if is_carrying:
				return drop_item()
			elif available_item:
				return try_carry(available_item)
		
		available_item.ItemType.INTERACT:
			return _handle_interact(available_item)
		
		available_item.ItemType.PICKUP:
			return _handle_pickup(available_item)
	
	return false
	

func try_carry(item: Node2D) -> bool:
	
	var types_list = item.ItemType
	var item_type = item.get_item_type()
	
	if is_carrying:
		return drop_item()
	
	if item_type != types_list.CARRY || item.item_interaction.active == false:
		return false
	
	actor = get_parent()
	
	carried_item = item
	is_carrying = true
	
	carried_item_original_parent = item.get_parent()
	carried_item_original_transform = item.global_transform
	
	carried_item_original_parent.remove_child(item)
	actor.add_child(item)
	item.position = carry_offset
	
	#item_carring.emit(item)
	
	return true

func _update_carried_item_position() -> void:
	if carried_item:
		carried_item.position = carry_offset

func drop_item() -> bool:
	
	if not is_carrying:
		print_debug("Não está carregando nada!")
		return false
		
	actor = get_parent()
	
	actor.remove_child(carried_item)
	
	var drop_position = _calculate_drop_position(actor)
	
	get_tree().root.add_child(carried_item)
	carried_item.global_position = drop_position
	
	carried_item.on_dropped()
	
	#item_dropped.emit(carried_item)
	
	carried_item.monitoring = true
	carried_item.monitorable = true
	
	carried_item = null
	is_carrying = false
	carried_item_original_parent = null
	carried_item_original_transform = Transform2D()
	
	return true

func _calculate_drop_position(carrier: CharacterBody2D) -> Vector2:
	var drop_offset: Vector2 = Vector2(0, 20)
	return carrier.global_position + drop_offset
	

func _on_item_nearby(body: Node2D) -> void:
	var item = body.get_parent() as Item
	
	#Checagem de item existente e interação
	if not item or not item.item_interaction.active:
		return
		
	available_item = item
	
func _on_item_far(body: Node2D) -> void:
	
	var item = body.get_parent() as Item
	
	if item and item == available_item:
		#item_lost.emit(item)
		available_item = null
	
	pass
	
func _handle_interact(item: Item) -> bool:
	item_interaction.emit()
	return true
	
func _handle_pickup(item: Item) -> bool:
	print_debug("Pegando item ", item)
	return true
