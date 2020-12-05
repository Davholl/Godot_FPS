extends Label

const MAX_LINES = 5;
var pickup_info = [];

func _ready():
	text = "";
	
func add_pickups_info(_pickup_type, amount: int):
	$RemoveInfoTimer.start();
	match _pickup_type:
		Pickup.PICKUP_TYPES.MACHINE_GUN:
			pickup_info.push_back("Picked up Machine Gun");
		Pickup.PICKUP_TYPES.MACHINE_GUN_AMMO:
			pickup_info.push_back("Picked up Machine Gun Ammo " + str(amount));
		Pickup.PICKUP_TYPES.SHOTGUN:
			pickup_info.push_back("Picked up Shotgun");
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			pickup_info.push_back("Picked up Shotgun Ammo " + str(amount));
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			pickup_info.push_back("Picked up Rocket Launcher");
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
			pickup_info.push_back("Picked up Rocket Launcher Ammo " + str(amount));
		Pickup.PICKUP_TYPES.HEALTH:
			pickup_info.push_back("Picked up Health Pack" + str(amount));
			
	while pickup_info.size() >= MAX_LINES:
		pickup_info.pop_front();
		
	update_display();
		
func update_display():
	text = "";
	for pickup_line in pickup_info:
		text += pickup_line + "\n";
	
func remove_pickups_info():
	if pickup_info.size() > 0:
		pickup_info.pop_front();
	update_display();
			
