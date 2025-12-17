class_name CarryComponent
extends Area2D

signal item_carring(item: BaseItem)
signal item_dropped(item: BaseItem)
signal item_found(item: BaseItem)
signal item_lost(item: BaseItem)

var available_item: BaseItem = null
var carried_item: BaseItem = null
var is_carrying: bool = false
var carry_offset: Vector2 = Vector2(0, -40)

#Guarda o status original do item para resturar/referenciar
var carried_item_original_parent: Node = null
var carried_item_original_transform: Transform2D = Transform2D()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	area_entered.connect(_on_item_nearby)
	area_exited.connect(_on_item_far)
	
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if is_carrying and carried_item:
		_update_carried_item_position()
	pass

func try_interact() -> bool:
	
	if not available_item:
		return false
	
	match available_item.get_item_type():
		BaseItem.ItemType.CARRY:
			if is_carrying:
				return drop_item()
			elif available_item:
				return try_carry(available_item)
		
		BaseItem.ItemType.INTERACT:
			return _handle_interact(available_item)
		
		BaseItem.ItemType.PICKUP:
			return _handle_pickup(available_item)
	
	return false
	

func try_carry(item: BaseItem) -> bool:
	
	#Guarda algumas informações do item
	var types_list = BaseItem.ItemType
	var item_type = item.get_item_type()
	
	#Se já estiver carregando o item, solta ele
	if is_carrying:
		return drop_item()
	
	#Se o item não for do tipo Carry não faz nada
	if item_type != types_list.CARRY || item.can_interact == false:
		return false
	
	#Variável para usos diversos:
	#Checagens do componente, AnimationTreeStateMachine e etc...
	carried_item = item
	is_carrying = true
	
	
	#Pega o CharacterBody que chamou o carry
	var carrier = get_parent() as CharacterBody2D	
	
	#Referencia o pai do item para conseguir removê-lo
	#Referencia o transform original do item para poder alterá-lo
	carried_item_original_parent = item.get_parent()
	carried_item_original_transform = item.global_transform
	
	#Remove o nó do item do lugar original e adiciona ao carrier
	#Cria um posição fixa com base no carrier
	carried_item_original_parent.remove_child(item)
	carrier.add_child(item)
	item.position = carry_offset
	
	#Executa função do item
	item.on_carry(carrier)
	
	#Emite sinal de picked_up
	item_carring.emit(item)
	
	return true

func _update_carried_item_position() -> void:
	if carried_item:
		carried_item.position = carry_offset

func drop_item() -> bool:
	
	if not is_carrying:
		print_debug("Não está carregando nada!")
		return false
		
	var carrier = get_parent() as CharacterBody2D
	
	carrier.remove_child(carried_item)
	
	var drop_position = _calculate_drop_position(carrier)
	
	get_tree().root.add_child(carried_item)
	carried_item.global_position = drop_position
	
	carried_item.on_dropped()
	
	item_dropped.emit(carried_item)
	print_debug(carried_item.item_name, " largado!")
	
	 # 3. Reativa a Area2D do item
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
	

func _on_item_nearby(body: Area2D) -> void:
	var item = body as BaseItem
	
	#Checagem de interação
	if not item or not item.can_interact:
		return
	
	available_item = item
	item_found.emit(item)
	
func _on_item_far(item: Area2D) -> void:
	
	if item and item == available_item:
		item_lost.emit(item)
		available_item = null
	
	pass
	
func _handle_interact(available_item: BaseItem) -> bool:
	print_debug("Interagindo...")
	return true
	
func _handle_pickup(available_item: BaseItem) -> bool:
	print_debug("Pegando item...")
	return true
