extends Skeleton

onready var body_bone : PhysicalBone = $Body;
onready var hip_bone : PhysicalBone = $Hip;

func _ready():
	physical_bones_start_simulation()

func _physics_process(delta):
	body_bone.apply_central_impulse(Vector3.UP * .99);
	hip_bone.apply_central_impulse(Vector3.DOWN * .5);
