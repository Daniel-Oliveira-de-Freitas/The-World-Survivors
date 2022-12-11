extends CharacterBody2D


var movement_speed = 40.0
var hp = 50
var maxhp = 50
var last_movement = Vector2.UP
var time = 0

var experience = 0
var experience_level = 1
var collected_experience = 0

@onready var sprite = $Sprite2D
@onready var walkTimer = $Timer


#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

#Javelins
var javelin_ammo = 0
var javelin_level = 0

#Enemy Related
var enemy_close = []

#GUI Elements
@onready var experienceBar = $GUILayer/GUI/ExperienceBar
@onready var labelLevel = $GUILayer/GUI/lbl_level
@onready var upgradeOptions = $GUILayer/GUI/LevelUp/UpgradeOptions
@onready var levelUpContainer = $GUILayer/GUI/LevelUp
@onready var itemOption = preload("res://Utility/item_option.tscn")
@onready var healthBar = $GUILayer/GUI/HealthBar
@onready var lblTime = $GUILayer/GUI/lbl_timer
@onready var collectedWeapons = $GUILayer/GUI/CollectedWeapons
@onready var collectedUpgrades = $GUILayer/GUI/CollectedUpgrades
@onready var collectedItems = preload("res://Player/GUI/item_container.tscn")
@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")


#Sounds
@onready var sndLevelUp = $GUILayer/GUI/LevelUp/snd_levelup


#Signals
signal playerdeath()


func _physics_process(_delta):
	movement()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	if x_mov > 0:
		sprite.flip_h = true
	elif x_mov < 0:
		sprite.flip_h = false
	
	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized()*movement_speed
	move_and_slide()

			
func get_random_target():
	var rand_choice_num = enemy_close.size()
	if rand_choice_num > 0:
		var array_num = randi_range(0,rand_choice_num - 1)
		return enemy_close[array_num].global_position
	else:
		return Vector2.UP


func _on_hitbox_hurt(damage, _angle, _knockback):

	if hp <= 0:
		death()
	healthBar.max_value = maxhp
	healthBar.value = hp

func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel,"position",Vector2(220,50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >=300:
		lblResult.text = "You Win"
		sndVictory.play()
	else:
		lblResult.text = "You Lose"
		sndLose.play()
		









func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			hp += 20
			hp = clamp(hp,0,maxhp)
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	levelUpContainer.visible = false
	levelUpContainer.position = Vector2(800,50)
	get_tree().paused = false
	



func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.grab()

	

func _on_button_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

