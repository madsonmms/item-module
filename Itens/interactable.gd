@abstract
class_name Interactable
extends Node2D

signal detection_start(detector: Node)
signal detection_end(detector: Node)

enum InteractableType {CARRY, PICKUP, INTERACT, PROP}
@export var interactable_type: InteractableType = InteractableType.INTERACT
@export var interaction_active : bool = true
@onready var collision: CollisionShape2D

var is_being_detected: bool = false
var current_detector: Node = null

#-- GETTERS :: START --#
func get_interactable_type() -> InteractableType:
	return interactable_type
#-- GETTERS :: END --#

#-- ABSTRACTS :: START --#
@abstract
func on_detection_start(_detector: Node) -> void

@abstract
func on_detection_end(_detector: Node) -> void
#-- ABSTRACTS :: END --#

#-- DETECTION INTERFACE :: START --#
func notify_detection_start(detector: Node) -> void:
	
	if not interaction_active:
		return
		
	is_being_detected = true
	current_detector = detector
	detection_start.emit(detector)
	
	_show_detection_feedback(detector)

func notify_detection_end(detector: Node) -> void:
	if not is_being_detected:
		return
	
	is_being_detected = false
	current_detector = null
	detection_end.emit(detector)
	
	_hide_detection_feedback()

# DETECTION FEEDBACK #
func _show_detection_feedback(_detector: Node) -> void:
	
	var label = get_node_or_null("InteractionLabel")
	if label:
		label.visible = true


func _hide_detection_feedback() -> void:
	
	var label = get_node_or_null("InteractionLabel")
	if label:
		label.visible = false
		
#-- DETECTION INTERFACE :: END --#
	
# PUBLIC INTERFACE - For other systems #
func notify_interaction_start(interactor: CharacterBody2D) -> void:
	_on_interaction_started(interactor)

func notify_carry_start(carrier: CharacterBody2D) -> void:
	_on_carry_started(carrier)

func notify_drop_start(carrier: CharacterBody2D) -> void:
	_on_drop_started(carrier)
# VIRTUAL METHODS - For specific items use #

#TYPE: INTERACT#
func _on_interaction_started(_interactor: CharacterBody2D) -> void:
	push_warning("_on_interaction_started() não implementado em: ", name)

#TYPE: CARRY#
func _on_carry_started(_carrier: CharacterBody2D) -> void:
	push_warning("_on_carry_started() não implementado em: ", name)
	
func _on_drop_started(_carrier: CharacterBody2D) -> void:
	push_warning("_on_drop_started() não implementado em: ", name)



# CONFIGURATION #
func set_interactable(value: bool) -> void:
	interaction_active = value
