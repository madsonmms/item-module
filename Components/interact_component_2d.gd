class_name InteractComponent
extends Node2D

# COMPONENT SIGNALS (for UI, sound, etc.)              
signal interaction_started(interactable: Interactable)
signal interaction_completed(interactable: Interactable)
signal interactable_detected(interactable: Interactable)
signal interactable_lost()

@export var carry_point: Marker2D

var available_body: Interactable = null
var carried_body: Interactable = null
var is_carrying: bool = false
var carry_offset: Vector2 = Vector2(0, 0)

var actor: CharacterBody2D

var current_detector : Node = null
var detection_enabled: bool = true


#-- COMPONENT SETUP :: START --#
func _ready() -> void:
	
	actor = get_parent() as CharacterBody2D
	_setup_detector()
	
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
	
	if not detection_enabled or not current_detector is RayCast2D:
		return
	
	var raycast = current_detector as RayCast2D
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var body = collider as Interactable
		
		if body and body.interaction_active:
			if body == carried_body:
				if available_body:
					available_body.notify_detection_end(self)
					available_body = null
				return
			
			if available_body and available_body != body:
				available_body.notify_detection_end(self)
			
			if body.interaction_active and available_body != body:
				available_body = body
				available_body.notify_detection_start(self)
				interactable_detected.emit(body)
			
	elif available_body:
		available_body.notify_detection_end(self)
		available_body = null
		interactable_lost.emit()


func _interactable_type_route(interactable: Interactable) -> bool:
	match available_body.get_interactable_type():
		available_body.InteractableType.CARRY:
			_handle_carry(interactable)
		
		available_body.InteractableType.INTERACT:
			return _handle_interact(interactable)
		
		available_body.InteractableType.PICKUP:
			return _handle_pickup(interactable)
		_:
			print("Tipo de interação não encontrado")
			return false
			
	return false
#-- COMPONENT SETUP :: END --#

#-- COMPONENT MAIN :: START --#
func try_interact() -> bool:
	
	if is_carrying:
		_handle_carry(carried_body)
		return false
	
	if not available_body:
		return false
	
	
	interaction_started.emit(available_body)
	
	var success = _interactable_type_route(available_body)
	
	if success:
		interaction_completed.emit(available_body)
	
	return success


func _handle_interact(interactable: Interactable) -> bool:
	interactable.notify_interaction_start(actor)
	return true


func _handle_carry(body: Interactable) -> bool:
	if is_carrying:
		return _drop_body()
	else:
		return _carry_body(body)


func _handle_pickup(body: Interactable) -> bool:
	return true
	
#-- COMPONENT MAIN :: END --#

#-- DROP FUNCTIONS :: START --#
func _carry_body(body: Interactable) -> bool:
	
	if is_carrying:
		return _drop_body()
	
	body.reparent(carry_point)
	body.notify_carry_start(actor)
	body.position = Vector2.ZERO
	
	carried_body = body
	is_carrying = true
	
	detection_enabled = false
	
	return true


func _drop_body() -> bool:
	
	if not is_carrying:
		print_debug("Não está carregando nada!")
		return false
	
	var drop_position = _calculate_drop_position(actor)
	
	carried_body.reparent(get_tree().root)
	carried_body.global_position = drop_position
	
	carried_body.notify_drop_start(actor)
	
	carried_body = null
	is_carrying = false
	
	detection_enabled = true
	
	return true


func _calculate_drop_position(carrier: CharacterBody2D) -> Vector2:
	var drop_offset: Vector2 = Vector2(0, 100)
	return carrier.global_position + drop_offset
	
#-- DROP FUNCTIONS :: END --#

#-- DETECTION :: START --#
func _on_area_body_entered(body: Node2D) -> void:
	var body_detected = body as Interactable
	
	if not body_detected or not body_detected.interaction_active:
		return
		
	available_body = body_detected
	
	available_body.notify_detection_start(self)
	
func _on_area_body_exited(body: Node2D) -> void:
	
	var body_detected = body as Interactable
	
	if body_detected and body_detected == available_body:
		available_body.notify_detection_end(self)
		available_body = null
	
	pass

func _clear_available_body() -> void:
	if available_body and available_body != carried_body:
		available_body.notify_detection_end(self)
	available_body = null
#-- DETECTION :: END --#
