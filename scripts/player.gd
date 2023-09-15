extends CharacterBody2D


@export var jump: float
@export var speed: float
@export_range(0, 1) var acceleration: float
@export_range(0, 1) var friction: float

@export var gun_offset: float
var gun_direction: float = 0

var gravity: float

var gun_inventory = [
	preload("res://scenes/weapons/pistol/pistol.tscn").instantiate(),
	# preload("res://scenes/weapons/ak_47/ak_47.tscn").instantiate(),
]
var gun_index = 0
@onready var gun: Gun = gun_inventory[gun_index]

var item_in_range: RigidBody2D = null

var is_using_mouse = true


func _ready():
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
	add_child(gun)


func _process(delta):	
	# Gravity
	velocity.y += gravity * delta
	
	# Movement
	var direction = get_direction()
	if direction != 0:
		velocity.x = lerp(velocity.x, direction * speed * delta * 100, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	move_and_slide()
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -(jump * delta * 100)

	if Input.is_action_pressed("shoot") and gun != null:
		gun.shoot()
		if gun.is_empty():
			var last_index = gun_index
			gun_index = next_gun_index()
			gun_inventory.remove_at(last_index)
			switch_gun()
			Input.action_release("shoot")
		
	if Input.is_action_just_pressed("reload") and gun != null:
		gun.start_reloading()

	if Input.is_action_just_pressed("next_weapon"):
		gun_index = next_gun_index()
		switch_gun()

	if Input.is_action_just_pressed("previous_weapon"):
		gun_index = previous_gun_index()
		switch_gun()

	if Input.is_action_just_pressed("interact"):
		if item_in_range != null:
			item_in_range.remove_child(item_in_range.item)
			gun_inventory.push_back(item_in_range.item)
			item_in_range.queue_free()
			if len(gun_inventory) == 1:
				switch_gun()
		
	gun_positioning()
	
	
func gun_positioning():
	if gun == null:
		return
	
	if not is_using_mouse:
		var gun_rotation = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down").angle()
		if gun_rotation != 0:
			gun_direction = gun_rotation
			gun.rotation = gun_direction
	else:
		gun.look_at(get_global_mouse_position())
	
	var rotation = fmod(gun.rotation, 2 * PI) + PI / 2
	if rotation > 0:
		gun.sprite.set_flip_v(false)
	else:
		gun.sprite.set_flip_v(true)


func switch_gun():
	remove_child(gun)
	if len(gun_inventory) == 0:
		gun = null
		return
	gun = gun_inventory[gun_index]
	add_child(gun)

	
func next_gun_index():
	var index = gun_index
	index += 1
	if index >= len(gun_inventory):
		index = 0
	return index
	
	
func previous_gun_index():
	var index = gun_index
	index -= 1
	if index <= 0:
		index = len(gun_inventory) - 1
	return index


func get_direction():
	var direction = 0
	if Input.is_action_pressed("left"):
		direction -= 1
	if Input.is_action_pressed("right"):
		direction += 1
	return direction


func _on_pickup_area_body_entered(body):
	item_in_range = body


func _on_pickup_area_body_exited(_body):
	item_in_range = null


func _input(event):
	if event is InputEventMouseMotion:
		is_using_mouse = true
		
	elif event is InputEventJoypadMotion:
		is_using_mouse = false
