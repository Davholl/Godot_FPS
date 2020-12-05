extends KinematicBody

onready var anim_player = $Graphics/AnimationPlayer;
onready var nav : Navigation = get_parent();

onready var health_manager = $HealthManager;
onready var character_mover = $CharacterMover;
onready var weapon_attacks = $AimAtObject.get_children();

var player = null;
var path = [];

export var sight_angle = 45.0;

export var turn_speed = 360.0;

export var attack_range = 2.0;
export var attack_rate = 0.5;
export var attack_anim_speed_mod = 0.5;

export var attack_damage = 10;

var attack_timer : Timer;
var can_attack = true;

signal attack;

enum STATES{IDLE, CHASE, ATTACK, DEAD}
var current_state = STATES.IDLE;

func _ready():
	attack_timer = Timer.new();
	attack_timer.wait_time = attack_rate;
	attack_timer.connect("timeout", self, "finish_attack");
	attack_timer.one_shot = true;
	add_child(attack_timer);
	
	health_manager.connect("gibbed", $Graphics, "hide");
	
	for weapon_attack in weapon_attacks:
		if weapon_attack.has_method("init"):
			weapon_attack.init(attack_damage, [self])
	
	player = get_tree().get_nodes_in_group("player")[0];
	var bone_attachments = $Graphics/Armature/Skeleton.get_children();
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is Hitbox:
				child.connect("hurt", self, "hurt");
				
	health_manager.init();
	health_manager.connect("dead", self, "set_state_dead");
	character_mover.init(self);
	set_state_idle();
				
func _process(delta):
	match current_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)

func set_state_idle():
	current_state = STATES.IDLE;
	anim_player.play("idle_loop")
	
func set_state_chase():
	current_state = STATES.CHASE;
	anim_player.play("walk_loop", 0.2);
	
func set_state_attack():
	current_state = STATES.ATTACK;
	
func set_state_dead():
	current_state = STATES.DEAD;
	anim_player.play("die");
	character_mover.freeze();
	$CollisionShape.disabled = true;
	
func process_state_idle(delta):
	if can_see_player():
		set_state_chase();

func process_state_chase(delta):
	if within_distance_of_player() and has_los_player():
		set_state_attack();
	var player_position = player.global_transform.origin;
	var our_pos = global_transform.origin;
	path = nav.get_simple_path(our_pos, player_position);
	var goal_position = player_position
	if path.size() > 1:
		goal_position = path[1];
	var dir = goal_position - our_pos;
	dir.y = 0;
	character_mover.set_move_vec(dir);
	face_direction(dir, delta);

func process_state_attack(delta):
	character_mover.set_move_vec(Vector3.ZERO);
	face_direction(global_transform.origin.direction_to(player.global_transform.origin), delta);
	if can_attack:
		if !within_distance_of_player() or !can_see_player():
			set_state_chase();
		else:
			start_attack();
	
func process_state_dead(delta):
	pass

func hurt(damage: int, dir : Vector3):
	if current_state == STATES.IDLE:
		set_state_chase();
		health_manager.hurt(damage, dir);
	health_manager.hurt(damage, dir);
	
func start_attack():
	can_attack = false;
	anim_player.play("attack", -1, attack_anim_speed_mod);
	attack_timer.start();
	
func emit_attack_signal():
	emit_signal("attack");
	
	
func finish_attack():
	can_attack = true;
	
func can_see_player():
	var dir_to_player = global_transform.origin.direction_to(player.global_transform.origin);
	var forwards = global_transform.basis.z;
	return rad2deg(forwards.angle_to(dir_to_player)) < sight_angle;
	
func has_los_player():
	var our_pos = global_transform.origin + Vector3.UP;
	var player_pos = player.global_transform.origin;
	
	var space_state = get_world().get_direct_space_state();
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1);
	if result:
		return false;
	return true;
	
func face_direction(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir);
	var turn_right = sign(global_transform.basis.x.dot(dir));
	if abs(angle_diff) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z);
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_right;
	
func alert(check_los=true):
	if current_state != STATES.IDLE:
		return;
	if check_los and !has_los_player():
		return;
	set_state_chase();
	
func within_distance_of_player():
	return global_transform.origin.distance_to(player.global_transform.origin) < attack_range;
