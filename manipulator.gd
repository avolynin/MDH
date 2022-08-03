extends Node3D

signal mode_changed

@onready var join0 = $Joint0
@onready var join1 = $Joint0/Joint1
@onready var join2 = $Joint0/Joint1/Joint2
@onready var join3 = $Joint0/Joint1/Joint2/Joint3
@onready var join4 = $Joint0/Joint1/Joint2/Joint3/Joint4
@onready var join5 = $Joint0/Joint1/Joint2/Joint3/Joint4/Joint5
@onready var grapper: Node3D = $Joint0/Joint1/Joint2/Joint3/Joint4/Joint5/Grapper

var joints = [join0, join1, join2, join3, join4, join5]
var theta_array = [5*PI/2, 0, 3*PI/2, PI, 0, 0]
var a_array = [0, 0, 0, 0, 0, 0]
var d_array = [0, 0, 0, 0, 0, 0]
var alpha_array = [PI/2, 0, PI/2, -PI/2, PI/2, 0]
var param_DHberg = [[], [], [], [], [], []]

var mode = "+"
enum TYPE_KINMATIC { INVERSE, FORWARD }
var kinematic = TYPE_KINMATIC.INVERSE

var forwardK
var inverseK

func set_paramDH():
	var jp0 = join0.global_transform.origin
	var jp1 = join1.global_transform.origin
	var jp2 = join2.global_transform.origin
	var jp3 = join3.global_transform.origin
	var jp4 = join4.global_transform.origin
	var jp5 = join5.global_transform.origin
	var gp = grapper.global_transform.origin
	
	d_array[0] = jp0.distance_to(jp1) + jp0.z
	a_array[1] = jp1.distance_to(jp2)
	d_array[3] = jp2.distance_to(jp4)
	d_array[5] = jp4.distance_to(gp)
func _ready():
	set_paramDH()
	forwardK = ForwardKinematic.new(a_array, d_array, alpha_array)
	match kinematic:
		TYPE_KINMATIC.INVERSE:
			inverseK = InverseKinematic.new(a_array, d_array, alpha_array)
			inverse_kinematic()
		TYPE_KINMATIC.FORWARD:
			forward_kinematic()
	
func input_inverse_kinematic():
	var velocity = Vector3.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 0.1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 0.1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 0.1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 0.1
	if Input.is_action_pressed("ui_5"):
		velocity.z += 0.1
	if Input.is_action_pressed("ui_2"):
		velocity.z -= 0.1
	
	if velocity != Vector3.ZERO:
		grapper.global_transform.origin += velocity
		print(grapper.global_transform.origin)
		inverse_kinematic()
		change_angles()
func input_forward_kinematic():
	var controlled_joint = -1
	if Input.is_action_pressed("ui_1"):
		controlled_joint = 1
	if Input.is_action_pressed("ui_2"):
		controlled_joint = 2
	if Input.is_action_pressed("ui_3"):
		controlled_joint = 3
	if Input.is_action_pressed("ui_4"):
		controlled_joint = 4
	if Input.is_action_pressed("ui_5"):
		controlled_joint = 5
	if Input.is_action_pressed("ui_0"):
		controlled_joint = 0
	
	if Input.is_action_pressed("ui_+"):
		set_mode("+")
	if Input.is_action_pressed("ui_-"):
		set_mode("-")
	
	if controlled_joint != -1:
		if mode == "+":
			theta_array[controlled_joint] += 0.1
		if mode == "-":
			theta_array[controlled_joint] -= 0.1
		change_angles()
		forward_kinematic()
func _input(event):
	match kinematic:
		TYPE_KINMATIC.INVERSE:
			input_inverse_kinematic()
		TYPE_KINMATIC.FORWARD:
			input_forward_kinematic()

func inverse_kinematic():
	forward_kinematic()
	var matrix = forwardK.calculate(theta_array)
	var matrixR03 = forwardK.calculate(theta_array, 3)
	var p06 = grapper.global_transform.origin

	#===
	var basis = Basis(Vector3(matrix[0][0], matrix[0][1], matrix[0][2]), 
	Vector3(matrix[1][0], matrix[1][1], matrix[1][2]), 
	Vector3(matrix[2][0], matrix[2][1], matrix[2][2]))
	var euler = basis.get_euler()
	
	var thetas2 = inverseK.calculate2(p06, euler)
	
	#===

	var R06 = [[matrix[0][0], matrix[0][1], matrix[0][2]],
	[matrix[1][0], matrix[1][1], matrix[1][2]],
	[matrix[2][0], matrix[2][1], matrix[2][2]]]
	var R03 = [[matrixR03[0][0], matrixR03[0][1], matrixR03[0][2]],
	[matrixR03[1][0], matrixR03[1][1], matrixR03[1][2]],
	[matrixR03[2][0], matrixR03[2][1], matrixR03[2][2]]]
	
	var thetas = inverseK.calculate1(p06, R06, R03)
	theta_array[0] = thetas[0]
	theta_array[1] = thetas[1]
	theta_array[2] = thetas[2]
	theta_array[3] = thetas[3]
	theta_array[4] = thetas[4]
	theta_array[5] = thetas[5]
	change_angles()

func forward_kinematic():
	var matrix = forwardK.calculate(theta_array)
	var basis = Basis(Vector3(matrix[0][0], matrix[0][1], matrix[0][2]), 
	Vector3(matrix[1][0], matrix[1][1], matrix[1][2]), 
	Vector3(matrix[2][0], matrix[2][1], matrix[2][2]))

	grapper.global_transform.basis = basis
	grapper.global_transform.origin = Vector3(matrix[0][3], matrix[1][3], matrix[2][3])
func change_angles():
	join0.rotation.z = theta_array[0]
	join1.rotation.z = theta_array[1]
	join2.rotation.z = theta_array[2]
	join3.rotation.z = theta_array[3]
	join4.rotation.z = theta_array[4]
	join5.rotation.z = theta_array[5]
	
	join1.rotation.x = alpha_array[0]
	join2.rotation.x = alpha_array[1]
	join3.rotation.x = alpha_array[2]
	join4.rotation.x = alpha_array[3]
	join5.rotation.x = alpha_array[4]

#region setget
#-------------------------------------

func set_mode(new_value):
	mode = new_value
	emit_signal("mode_changed", mode)
func get_mode():
	return mode

#-------------------------------------
