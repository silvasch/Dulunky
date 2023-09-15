@tool
class_name Gun
extends Node2D


@export var bullets_per_second: float = 1
@onready var bullet_delay: float = 1 / bullets_per_second
@onready var bullet_timer: float = bullet_delay

@export var reload_time: float = 3
@onready var reload_timer: float = reload_time
var is_reloading: bool = false

@export var bullets_per_magazin: int = 10
@onready var bullet_count: int = bullets_per_magazin

@export var magazines_included: int = 5
@onready var magazines_left: int = magazines_included - 1

@export var texture: Texture2D
@onready var sprite

var animation_player = AnimationPlayer.new()


func _ready():
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(2, 2)
	add_child(sprite)
	
	var fire_animation = Animation.new()
	var fire_track_index = fire_animation.add_track(Animation.TYPE_VALUE)
	fire_animation.track_set_path(fire_track_index, "%s:position:x" % sprite.name)
	fire_animation.track_insert_key(fire_track_index, 0.0, 0)
	fire_animation.track_insert_key(fire_track_index, 0.04, -10)
	fire_animation.track_insert_key(fire_track_index, 0.08, 0)
	fire_animation.length = 0.08
	
	var reload_animation = Animation.new()
	var reload_track_index = reload_animation.add_track(Animation.TYPE_VALUE)
	reload_animation.track_set_path(reload_track_index, "%s:rotation" % sprite.name)
	reload_animation.track_insert_key(reload_track_index, 0.0, deg_to_rad(360))
	reload_animation.track_insert_key(reload_track_index, reload_time / 3, deg_to_rad(240))
	reload_animation.track_insert_key(reload_track_index, reload_time / 3 * 2, deg_to_rad(120))
	reload_animation.track_insert_key(reload_track_index, reload_time, 0)
	reload_animation.length = reload_time
	
	
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("fire", fire_animation)
	animation_library.add_animation("reload", reload_animation)

	animation_player.add_animation_library("gun", animation_library)

	add_child(animation_player)


func _process(delta):
	bullet_timer -= delta
	
	if is_reloading:
		reload_timer -= delta
		
		if reload_timer <= 0:
			is_reloading = false
			magazines_left -= 1
			bullet_count = bullets_per_magazin
			reload_timer = reload_time


func shoot():
	if bullet_count < 1:
		return
		
	if bullet_timer > 0:
		return
		
	bullet_count -= 1
	bullet_timer = bullet_delay

	animation_player.play("gun/fire")


func start_reloading():
	if magazines_left < 1:
		return
		
	is_reloading = true
	
	animation_player.play("gun/reload")
	
	
func is_empty():
	return bullet_count == 0 && magazines_left == 0
