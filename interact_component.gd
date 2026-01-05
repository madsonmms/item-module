class_name InteractComponent
extends Area2D

# SINAIS DO COMPONENTE (para UI, som, etc.)
signal item_available(item: Item)        
signal item_unavailable()                
signal interaction_started(item: Item)   
signal interaction_completed(item: Item) 
signal interaction_failed(reason: String)

@export var carry_point: Marker2D

var available_item: Item = null
var carried_item: Item = null
var is_carrying: bool = false
var carry_offset: Vector2 = Vector2(0, 0)

var actor: CharacterBody2D

#Guarda o status original do item para resturar o item
var carried_item_original_parent: Node = null
var carried_item_original_transform: Transform2D = Transform2D()

func _ready() -> void:
	
	area_entered.connect(_on_item_nearby)
	area_exited.connect(_on_item_far)
	
	pass

func _process(_delta: float) -> void:
	#if is_carrying and carried_item:
		#_update_carried_item_position()
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
	

func try_carry(item: Item) -> bool:
	
	var types_list = item.ItemType
	var item_type = item.get_item_type()
	
	if is_carrying:
		return drop_item()
	
	if item_type != types_list.CARRY || item.interaction_area.active == false:
		return false
	
	actor = get_parent()
	
	is_carrying = true
	
	item.freeze = true
	item.reparent(carry_point)
	item.on_interact(actor)
	item.position = Vector2.ZERO
	
	item.collision.disabled = true
	
	carried_item = item
	
	return true


func drop_item() -> bool:
	
	if not is_carrying:
		print_debug("Não está carregando nada!")
		return false
		
	actor = get_parent()
	
	actor.interact_component.carry_point.remove_child(carried_item)
	
	var drop_position = _calculate_drop_position(actor)
	
	get_tree().root.add_child(carried_item)
	carried_item.global_position = drop_position
	
	carried_item.on_dropped()
	
	carried_item.freeze = false
	carried_item.collision.disabled = false
	
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
	
	if not item or not item.interaction_area.active:
		return
		
	available_item = item
	
func _on_item_far(body: Node2D) -> void:
	
	var item = body.get_parent() as Item
	
	if item and item == available_item:
		#item_lost.emit(item)
		available_item = null
	
	pass
	
func _handle_interact(item: Item) -> bool:
	return true
	
func _handle_pickup(item: Item) -> bool:
	print_debug("Pegando item ", item)
	return true
