class_name InteractComponent
extends Node2D

# COMPONENT SIGNALS (for UI, sound, etc.)              
signal interaction_started(item: Item)
signal interaction_completed(item: Item)

@export var carry_point: Marker2D

var available_item: Item = null
var carried_item: Item = null
var is_carrying: bool = false
var carry_offset: Vector2 = Vector2(0, 0)

var actor: CharacterBody2D

var current_detector : Node = null

func _ready() -> void:
	
	actor = get_parent() as CharacterBody2D
	_setup_detector()
	
	#area_entered.connect(_on_item_nearby)
	#area_exited.connect(_on_item_far)
	
	pass

func _process(_delta: float) -> void:
	if current_detector is RayCast2D:
		_update_raycast_detection()

func _setup_detector() -> void:
	for child in get_children():
		if child is Area2D or child is RayCast2D:
			current_detector = child
			_connect_detector_signals()
			print_debug("Detector configurado: ", current_detector.name)
			
	if not current_detector:
		push_warning("[InteractionComponent] Nenhum detector configurado ou tipo inválido, insira um detector válido! (Area2D | Raycast2D)")

func _connect_detector_signals() -> void:
	if current_detector is Area2D:
		current_detector.body_entered.connect(_on_area_body_entered)
		current_detector.body_exited.connect(_on_area_body_exited)
	else:
		return

func _update_raycast_detection() -> void:
	if not current_detector is RayCast2D:
		push_warning("[InteractionComponent] Tipo de Raycast inválido. Verifique o componente")
		pass
	
	var raycast = current_detector as RayCast2D
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var item = collider.get_parent() as Item
		
		print_debug(collider, item)

# COMPONENT MAIN #
func try_interact() -> bool:
	
	if not available_item:
		return false
	
	interaction_started.emit(available_item)
	
	var success = _item_type_route(available_item)
	
	if success:
		interaction_completed.emit(available_item)
	
	return success
	

func _item_type_route(item: Item) -> bool:
	match available_item.get_item_type():
		available_item.ItemType.CARRY:
			_handle_carry(item)
		
		available_item.ItemType.INTERACT:
			return _handle_interact(item)
		
		available_item.ItemType.PICKUP:
			return _handle_pickup(item)
		_:
			print("Tipo de interação não encontrado")
			return false
			
	return false
	
func _handle_interact(item: Item) -> bool:
	item.notify_interaction_start(actor)
	return true

func _handle_carry(item: Item) -> bool:
	if is_carrying:
		return _drop_item()
	else:
		return _carry_item(item)
	
func _handle_pickup(item: Item) -> bool:
	print_debug("Pegando item ", item)
	return true


# DROP FUNCTIONS #
func _carry_item(item: Item) -> bool:
	
	if is_carrying:
		return _drop_item()
	
	item.reparent(carry_point)
	item.notify_carry_start(actor)
	item.position = Vector2.ZERO
	
	carried_item = item
	is_carrying = true
	
	return true


func _drop_item() -> bool:
	
	if not is_carrying:
		print_debug("Não está carregando nada!")
		return false
	
	var drop_position = _calculate_drop_position(actor)
	
	carried_item.reparent(get_tree().root)
	carried_item.global_position = drop_position
	
	carried_item.notify_drop_start(actor)
	
	carried_item = null
	is_carrying = false
	
	return true

func _calculate_drop_position(carrier: CharacterBody2D) -> Vector2:
	var drop_offset: Vector2 = Vector2(0, 100)
	return carrier.global_position + drop_offset
	


# DETECTION #
func _on_area_body_entered(body: Node2D) -> void:
	var item = body.get_parent() as Item
	
	if not item or not item.is_interactable:
		return
		
	available_item = item
	
func _on_area_body_exited(body: Node2D) -> void:
	
	var item = body.get_parent() as Item
	
	if item and item == available_item:
		#item_lost.emit(item)
		available_item = null
	
	pass
