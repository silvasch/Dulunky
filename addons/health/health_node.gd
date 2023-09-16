@tool
class_name Health
extends Node


@export var max_health: float = 100
@onready var health: float = max_health


func is_dead():
	return health <= 0
