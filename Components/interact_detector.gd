class_name InteractDetector
extends Node

signal interactable_detected(interactable: Interactable)
signal interactable_lost()

var current_detector: Node

# Found interactables
var detected_interactables: Array[Interactable] = []
var available_body: Interactable = null
var nearest: Interactable
var last_nearest: Interactable = null

func get_detector_type() -> Node2D:
	return null

func setup_detector(detector) -> Node:
	if detector is Area2D or detector is RayCast2D:
		current_detector = detector
		_connect_detector_signals()
		print_debug("Detector configurado: ", current_detector.name)
			
	if not current_detector:
		push_warning("[InteractionComponent] Nenhum detector configurado ou tipo inválido, insira um detector válido! (Area2D | Raycast2D)")

	return current_detector
	
func update_raycast_detector(_carried_body: Node) -> Node:
	if not current_detector is RayCast2D:
		return null
	
	var raycast = current_detector as RayCast2D
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var body = collider as Interactable
		
		if body and body.interaction_active:
			if body == _carried_body:
				if available_body:
					available_body.notify_detection_end(self)
				return null
			
			if available_body and available_body != body:
				available_body.notify_detection_end(self)
			
			if body.interaction_active and available_body != body:
				available_body = body
				available_body.notify_detection_start(self)
				interactable_detected.emit(body)
				return available_body
			
	elif available_body:
		available_body.notify_detection_end(self)
		interactable_lost.emit()
		return null
	
	return available_body


func _connect_detector_signals() -> void:
	if current_detector is Area2D:
		current_detector.body_entered.connect(_on_area_body_entered)
		current_detector.body_exited.connect(_on_area_body_exited)
	else:
		return


#-- DETECTION :: START --#
func _on_area_body_entered(body: Node) -> void:
	var interactable = body as Interactable
	
	if not interactable or not interactable.interaction_active:
		return
	
	if not available_body:
		available_body = interactable
	
	detected_interactables.append(interactable)
	
	
func _on_area_body_exited(body: Node) -> void:
	
	var interactable = body as Interactable
	
	detected_interactables.erase(interactable)
	
	if interactable and detected_interactables == []:
		available_body.notify_detection_end(self)
		available_body = null
	
	

func get_nearest_body() -> Node:
	if current_detector is not Area2D:
		print_debug("Detector não é area2D")
		return
	
	var bodies = current_detector.get_overlapping_bodies()
	var nearest_body: Node2D = null
	var min_dist: float = INF
	
	for body in bodies:
		
		var interactable = body as Interactable
		
		if interactable and interactable.interaction_active:
			var dist = current_detector.global_position.distance_squared_to(body.global_position)
			
			if dist < min_dist:
				min_dist = dist
				nearest_body = interactable
		
				
	return nearest_body

func update_area_detector() -> void:
	nearest = get_nearest_body()
	if last_nearest and last_nearest != nearest:
		last_nearest.notify_detection_end(self)
	if nearest:
		nearest.notify_detection_start(self)
		last_nearest = nearest
	
	
func _clear_available_body() -> void:
	for interactable in detected_interactables:
		interactable.notify_detection_end(self)
		
	detected_interactables.clear()
	interactable_lost.emit()
		
#-- DETECTION :: END --#
