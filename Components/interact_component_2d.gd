class_name InteractComponent
extends Node2D

# COMPONENT SIGNALS (for UI, sound, etc.)              
signal interaction_started(interactable: Interactable)
signal interaction_completed(interactable: Interactable)

# Inspector configurations
@export var carry_point: Marker2D
@export var detector: Node2D
@export var detection_enabled: bool = true

# Found interactables
var available_body: Interactable = null

# Carrying
var carried_body: Interactable = null
var is_carrying: bool = false
var carry_offset: Vector2 = Vector2(0, 0)

# Actor
var actor: CharacterBody2D

# Detection
var current_detector : Node = null
var detection: InteractDetector = InteractDetector.new()
var nearest: Interactable
var last_nearest: Interactable = null


#-- COMPONENT SETUP :: START --#
func _ready() -> void:
	
	actor = get_parent() as CharacterBody2D
	
	current_detector = detection.setup_detector(detector)
	
	pass


func _process(_delta: float) -> void:
	if current_detector is RayCast2D:
		available_body = detection.update_raycast_detector(carried_body)
	if current_detector is Area2D:
		nearest = detection._get_nearest_body()
		if last_nearest and last_nearest != nearest:
			last_nearest.notify_detection_end(self)
		if nearest:
			nearest.notify_detection_start(self)
			last_nearest = nearest
		
			

#-- COMPONENT MAIN :: START --#
func try_interact() -> bool:
	
	if is_carrying:
		_handle_carry(carried_body)
		return false
	
	if current_detector is Area2D:
		var nearest = detection._get_nearest_body()
		
		if nearest:
			available_body = nearest
	
	if not available_body:
		return false
	
	interaction_started.emit(available_body)
	
	var success = _interactable_type_route(available_body)
	
	if success:
		interaction_completed.emit(available_body)
	
	return success


func _handle_interact(body: Interactable) -> bool:
	body.notify_interaction_start(actor)
	return true


func _handle_carry(body: Interactable) -> bool:
	if is_carrying:
		return _drop_body()
	else:
		return _carry_body(body)


func _handle_pickup(_body: Interactable) -> bool:
	print_debug("[InteractComponent] tentando pickup")
	return true
	
#-- COMPONENT MAIN :: END --#

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
