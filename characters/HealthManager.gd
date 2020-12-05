extends Spatial

var blood_spray = preload("res://effects/BloodSpray.tscn")
var gibs = preload("res://effects/Gibs.tscn")

signal dead;
signal hurt;
signal healed;
signal health_changed;
signal gibbed;

export var max_health = 100;
var current_health = 1;

export var gib_at = -10;

func _ready():
	pass
	
func init():
	current_health = max_health;
	emit_signal("health_changed", current_health);
	
func hurt(damage: int, dir: Vector3, damage_type="normal"):
	spawn_blood(dir);
	if current_health <= 0:
		return
	current_health -= damage
	if current_health <= gib_at:
		#TODO make gibs
		emit_signal("gibbed");
		spawn_gibs()
	if current_health <= 0:
		emit_signal("dead");
		print("dead")
	else:
		emit_signal("hurt");
		
	emit_signal("health_changed", current_health);
	print("hurt ", damage, "current health ", current_health);
	
func heal(amount: int):
	if current_health <= 0:
		return
	current_health += amount;
	if current_health > max_health:
		current_health = max_health
	emit_signal("healed")
	emit_signal("health_changed", current_health);


func spawn_blood(dir):
	var blood_spray_inst = blood_spray.instance();
	get_tree().get_root().add_child(blood_spray_inst);
	blood_spray_inst.global_transform.origin = global_transform.origin;
	
	if dir.angle_to(Vector3.UP) < 0.00005:
		return;
	if dir.angle_to(Vector3.DOWN) < 0.00005:
		blood_spray_inst.rotate(Vector3.RIGHT, PI);
		return;
	
	var y = dir;
	var x = y.cross(Vector3.UP);
	var z = x.cross(y);
	
	blood_spray_inst.global_transform.basis = Basis(x, y, z);
	
func spawn_gibs():
	var gibs_inst = gibs.instance();
	get_tree().get_root().add_child(gibs_inst);
	gibs_inst.global_transform.origin = global_transform.origin;
	gibs_inst.enable_gibs();
	
func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.HEALTH:
			heal(ammo)
			print("picked health", ammo);
