extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	if Input.is_key_pressed(KEY_Z) : 
		.translate(Vector3(0,5,0))
	if Input.is_key_pressed(KEY_S) : 
		.translate(Vector3(0,-5,0))
	if Input.is_key_pressed(KEY_D) : 
		.translate(Vector3(-5 , 0 , 0))
	if Input.is_key_pressed(KEY_Q) : 
		.translate(Vector3(5,0,0))
	if Input.is_key_pressed(KEY_UP) :
		.translate(Vector3(0,0,5))
	if Input.is_key_pressed(KEY_DOWN) : 
		.translate(Vector3(0,0,-5))
	pass
