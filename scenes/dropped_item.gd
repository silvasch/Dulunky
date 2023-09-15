extends RigidBody2D


enum ItemType {
	GUN,
}


@export_enum("Gun") var item_type: int

@export var item_scene: PackedScene
@onready var item = item_scene.instantiate()


func _ready():
	add_child(item)


func _process(delta):
	pass
