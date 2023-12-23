extends Object

class_name Propagator 

var numLabels : int = 0
var settings : InputSettings


func _init(new_settings : InputSettings):
	settings = new_settings
	numLabels = settings.numLabels


static func pickFromWeights(weights : Array , n : int) -> int : 
	var sum : float = 0 
	var cumulativeSums : Array = []
	var rand = RandomNumberGenerator.new()
	for i in n : 
		sum += weights[i]
		cumulativeSums.append(sum)
	if sum == 0 : 
		return -1
	
	var randomValue = sum * float(rand.randi()/4294967295.0)
	for i in n : 
		if randomValue < cumulativeSums[i] : 
			return i 
	return - 1

func pickLabel(x : int , y : int , z :int) -> int : 
	var weights : Array = []
	weights.resize(numLabels)
	for i in numLabels : 
		if isPossible(x , y , z , i) : 
			weights[i] = settings.weights[i]
		else : 
			weights[i] = 0.0
	var label : int = pickFromWeights(weights , numLabels)
		
	if label == -1 : 
		return -1 
	var position : Array = []
	position.resize(3)
	position[0] = x 
	position[1] = y
	position[2] = z
	var success : bool = setBlockLabel(label,position)
		
	if success : 
		return label
	else : 
		return -1

func printPossible(x , y , z) : 
	print("possible labels : ")
	for i in numLabels : 
		if isPossible(x,y,z,i) : 
			print(i)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func isPossible(x : int , y : int , z : int , label : int) -> bool : 
	print("do something")
	return false

func setBlockLabel(label : int , position : Array) -> bool :
	print("do something")
	return false

func removeLabel(label : int , position : Array) : 
	print("do something")

func resetBlock() : 
	print("do something")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
