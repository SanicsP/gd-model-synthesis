extends Object

class_name InputSettings

var name_:String = ""


# Whether to use the AC-4 algorithm instead of AC-3.
var useAc4:bool = false


# The size of the output that should be generated.
var size : Array = [] # size 3


# The weight of each label. Labels with more weight are more
#likely to be selected.
var block_size : Array = [] #size 3

# The weight of each label. Labels with more weight are more
# likely to be selected.

var weights : Array = []

var numLabels : int = 0

#These labels are used to generate the initial model. These are
# only needed if we are modifying in blocks.
var initial_labels : Array = []

#The transition describes which labels can be next to each other.
#When transition[direction][labelA][labelB] is true that means labelA
#can be just below labelB in the specified direction where x = 0, y = 1, z = 2.
var transition : Array = [[[]]]

# Which labels does each label support in each direction.
var supporting : Array = [[[]]]

#The amount that each label is supported in each direction.
var supportCount : Array = [[]]

#The ending of the file for the tiled model.
var tileModelSufix : String = ""

#The image bitmaps.
var tileImages : Array = [[]]

# The width and height in pixels.
var tileWidth : int = 0
var tileHeight : int = 0

# If the output is periodic in X and Y.
var periodic : bool = false

#The number of dimensions.
var numDims : int = 3

#The type of intput
var type : String = ""
var subset : String =""

# These only apply to overlapping examples
# Whether the input is periodic.
var periodicInput : bool = true

#The ground tile. -1 if one is not present.
var ground : int = -1

# The type of symetry 
var symetry : int = 0











# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#Return the index for an RGB image.
static func rgb(x:int, y:int, N:int) -> int:
	return 3*(x+y*N)
	
#Return the index for an RGBA image.
static func rgba( x :int, y :int, N:int ) ->int: 
	return 4*(x+y*N)
	
#Read a floating point attribute from an XML node.
static func parseFloat(node:XMLParser,attribute:String,defaultValue:float) -> float :
	var result : float = 0
	var attribute_str : String = node.get_named_attribute_value_safe(attribute)
	if len(attribute_str) == 0:
		return defaultValue
	else : 
		result = float(attribute_str)
		return result
	
#Read an integer attribute from an XML node.
static func parseInt(node:XMLParser, attribute, defaultValue) -> int:
	var result : int = 0
	var attribute_str : String = node.get_named_attribute_value_safe(attribute)
	if len(attribute_str) == 0:
		return defaultValue
	else : 
		result = int(attribute_str)
		return result 
	
	
#Read a Boolean attribute from an XML node.

static func parseBool(node:XMLParser, attribute, defaultValue:bool) -> bool:
	var attribute_str : String = node.get_named_attribute_value_safe(attribute)
	if len(attribute_str) == 0:
		return defaultValue
	else : 
		if attribute_str == "True" : 
			return true
		elif attribute_str =="False" : 
			return false
		else : 
			return defaultValue
	
#Find an initial label that can tile the plane.
static func findInitialLabel(settings:InputSettings) :
	settings.initial_labels = [0]
	var groundFound : bool = false
	var transition : Array = settings.transition
	for i in range(settings.numLabels) : 
		if(transition[0][i][i] and transition[1][i][i]) :
			settings.initial_labels[0] = i
			groundFound = true
			break 
	var ModfifyInBlocks : bool = (settings.block_size[0] < settings.size[0] or settings.block_size[1] < settings.size[1])
	if ModfifyInBlocks and not groundFound : 
		print("The example model has no tileable ground plane. The new model can not be modified in blocks.\n")
	pass
	
#Create a transition matrix.
static func createTransition(numLabels :int)-> Array :
	var array = []
	array.resize(3)    # X-dimension
	for x in 3:    # this method should be faster than range since it uses a real iterator iirc
		array[x] = []
		array[x].resize(numLabels)    # Y-dimension
		for y in numLabels:
			array[x][y] = []
			array[x][y].resize(numLabels)
			for z in numLabels :   # Z-dimension
				array[x][y][z] = false
	return array
	
#Delete a transition matrix.
static func deleteTransition(transition : Array,numLabels:int) : 
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
