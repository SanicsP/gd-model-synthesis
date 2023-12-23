extends Object

class_name parseTiledModel


static func parseTiledModel(settings) -> InputSettings:
	var path = "samples/"+settings.name_
	var modelFile = File.new()
	modelFile.open(path, File.READ)
	
	if not modelFile.is_open() : 
		print("file error")
		return null
	modelFile.get_line()
	modelFile.get_line()
	modelFile.get_line()
	var coord_line : String = modelFile.get_line() 
	#print("coord line : " , coord_line)

	#Read in the size and create the example model.
	var sizes : Array = coord_line.split(" ")
	var xSize : int = int(sizes[0])
	var ySize : int = int(sizes[1])
	var zSize :int = int(sizes[2])
	var example : Array = make_3d_array(xSize , ySize , zSize)
	
	modelFile.get_line()
	

	#code added because the difference between std::ifstream and File classe
	var modelStr : String = ""

	for i in range((xSize+1)*zSize) : 
		modelStr += " " + modelFile.get_line()
	
	#modelStr = modelStr.replace("\n","  ")
	
	var example_values = convert_model_str(modelStr , xSize , ySize , zSize)
	##-------------------------------------------------------------------------

	# Read in the labels in the example model
	var buffer : int = 0
	var current_label : int = example_values[buffer]
	for z in range(zSize) :
		for x in range(xSize):
			for y in range(ySize) :
				example[x][y][z] = current_label
				buffer += 1
				if buffer < x*y*z:
					current_label = example_values[buffer]

	
	#print("sizes : " , String(xSize) + " " , String(ySize) + " " , String(zSize))
	
	#// Find the number of labels in the model.
	var numLabels : int = 0
	for x in range(xSize) :
		for y in range(ySize) :
			for z in range(zSize) : 
				numLabels = max(numLabels,example[x][y][z])
	numLabels += 1
	settings.numLabels = numLabels

	# The transition describes which labels can be next to each other.
	# When transition[direction][labelA][labelB] is true that means labelA
	# can be just below labelB in the specified direction where x = 0, y = 1, z = 2.
	var transition : Array = InputSettings.createTransition(numLabels)
	settings.transition = transition
	
	#Compute the transition.
	for x in range(xSize-1) : 
		for y in range(ySize) : 
			for z in zSize : 
				var labelA : int = example[x][y][z]
				var labelB : int = example[x+1][y][z]
				transition[0][labelA][labelB] = true
	
	for x in range(xSize) : 
		for y in range(ySize-1) :
			for z in range(zSize) : 
				var labelA :int = example[x][y][z]
				var labelB : int = example[x][y+1][z]
				transition[1][labelA][labelB] = true

	for x in range(xSize) : 
		for y in range(ySize) :
			for z in range(zSize-1) : 
				var labelA :int = example[x][y][z]
				var labelB : int = example[x][y][z+1]
				transition[2][labelA][labelB] = true
	
	#// The number of labels of each type in the model.
	var labelCount : Array = []
	labelCount.resize(numLabels)
	for i in range(numLabels) :
		labelCount[i] = 0
	for x in range(xSize) : 
		for y in range(ySize) : 
			for z in range(zSize) :
				labelCount[example[x][y][z]] += 1
	
	# We could use the label count, but equal weight also works.
	for i in range(numLabels) : 
		settings.weights.append(1.0)
	
	# Find the label that should initially appear at the very bottom.
	# And find the ground plane label.
	var bottomLabel : int = -1
	var groundLabel : int = -1

	var onBottom : Array = []
	
	onBottom.resize(numLabels)
	for i in range(numLabels) : 
		onBottom[i] = 0
	for x in range(xSize) : 
		for y in range(ySize):
			onBottom[example[x][y][0]] += 1
	
	# The bottom and ground labels should be tileable and appear frequently.
	var bottomCount : int = 0 
	for i in numLabels : 
		if transition[0][i][i] and transition[1][i][i] and (onBottom[i]>bottomCount) :
			bottomLabel = i
			bottomCount = onBottom[i]
	
	if bottomLabel != -1 : 
		var groundCount : int = 0
		for i in range(numLabels) : 
			if transition[0][i][i] and transition[1][i][i] and transition[2][bottomLabel][i] and transition[2][i][0] and (labelCount[i]>groundCount):
				 groundLabel = i
				 groundCount = labelCount[i]
	
	if groundLabel == -1 or bottomLabel == -1 : 
		var modifyInBlocks : bool = (settings.block_size[0] < settings.size[0] or settings.block_size[1] < settings.size[1]) 
		if modifyInBlocks : 
			print( "The example model has no tileable ground plane. The new model can not be modified in blocks.\n")
	
	#set the initials labels 
	settings.initial_labels = []
	settings.initial_labels.resize(settings.size[2])
	settings.initial_labels[0] = bottomLabel
	settings.initial_labels[1] = groundLabel

	settings.transition = transition

	for z in range(settings.size[2]) : 
		if z < zSize : 
			settings.initial_labels[z] = example[0][0][z]
		else : 
			settings.initial_labels[z] = 0
	
	#delete the example model 
	#godot will take care of it lol ....


	return settings
# Called when the node enters the scene tree for the first time.

static func convert_model_str(model_str:String , x:int , y:int , z:int) -> Array: 
	var exemple_array : Array = []
	var splited : Array = model_str.split(" ",false)
	print(len(splited))
	for i in range(x*y*z) :
		exemple_array.append(int(splited[i])) 
		pass
		#exemple_array = int(splited[i])
	return exemple_array
static func make_3d_array(x:int,y:int,z:int)->Array:
	var array_3d : Array = []
	array_3d.resize(x)
	for i in range(x) : 
		array_3d[i] = []
		array_3d[i].resize(y)
		for j in range(y):
			array_3d[i][j] = []
			array_3d[i][j].resize(z)
			for k in range(z) : 
				array_3d[i][j][k] = 0
	return array_3d
func _ready():
	pass # Replace with function body.



