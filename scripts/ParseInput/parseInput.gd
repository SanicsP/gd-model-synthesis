extends Node


class_name ParseSampleInput

# Find the labels that support each label in each direction.
static func computeSupport(settings : InputSettings) -> InputSettings:
	var N : int = settings.numLabels
	settings.supporting.resize(N)
	settings.supportCount.resize(N)
	var transition : Array = settings.transition
	for c in range(N) : 
		var numDirections : int = 2 * settings.numDims
		var supportingC : Array = [[]]
		var supportCountC : Array = [numDirections]
		for dir in range(numDirections) : 
		
			var supportingDir : Array = []
			var dim : int = dir/2
			var sign_ : bool= dir % 2 == 0
		
			if sign_ :
				for b in range(N) : 
					if transition[dim][b][c] :
						#b supports c in direction dir
						supportingDir.append(b)
			else:
				for b in range(N) : 
					if transition[dim][c][b]:
						#n supports c in direction dir
						supportingDir.append(b)

			supportingC[dir] = supportingDir
			supportCountC[dir^1] = len(supportingDir)
		
		settings.supporting[c] = supportingC
		settings.supportCount[c] = supportCountC

	return settings				
	pass 

static func parseInput(node : XMLParser , inputTime_micro) -> InputSettings : 
	var startInput : float = Time.get_datetime_dict_from_system()["second"]
	var settings : InputSettings = InputSettings.new()
	settings.block_size.resize(3)
	settings.size.resize(3)

	settings.name_ = node.get_named_attribute_value_safe("name")
	settings.size[0] = InputSettings.parseInt(node , "width" , 0)
	settings.size[1] = InputSettings.parseInt(node , "length" , 0)
	settings.size[2] = InputSettings.parseInt(node , "height" , 0)

	settings.block_size[0] = InputSettings.parseInt(node , "BlockWidth" , 0)
	settings.block_size[1] = InputSettings.parseInt(node , "BLocLength" , 0)
	settings.block_size[2] = InputSettings.parseInt(node , "BLocHeight" , 0)

	settings.subset = node.get_named_attribute_value_safe("subset")
	
	#Switch length and height if length is 0.
	if settings.size[1] == 0 : 
		var temp : int = settings.size[2] 
		settings.size[2] = settings.size[1]
		settings.size[1] = temp
	settings.size[2] = max(settings.size[2] , 1)

	# Compute the block size if not given or if too large.
	for dim in range(3) :
		if settings.block_size[dim] > settings.size[dim] : 
			print("ERROR: The block size cannot be larger than the output size.")
			settings.block_size[dim] = settings.size[dim]
		if settings.block_size[dim] == 0 : 
			settings.block_size[dim] = settings.size[dim]
		
	settings.periodic = InputSettings.parseBool(node , "periodic" , false)
	if settings.periodic and (settings.block_size[0] < settings.size[0] or settings.block_size[1] < settings.size[1] ) : 
		print("Periodic not implemented when modifying in blocks")
	
	settings.type = node.get_node_name()
	if settings.type == "simpletiled" : 
		settings.numDims = 2
		# InputSettings = parseSimpleTiled(settings) unfinished
	elif settings.type == "overlaping" :
		settings.numDims = 2
		settings.tileWidth = InputSettings.parseInt(node , "N" , 0)
		settings.tileHeight = settings.tileWidth
		settings.periodic = InputSettings.parseBool(node , "periodicInput" , true)
		settings.symetry = InputSettings.parseBool(node , "symetry" , 8)
		var hasGround : bool = InputSettings.parseInt(node , "ground" , 1234) != 1234
		settings.ground = 1 if hasGround else -1
		#settings = parseOverlapping(settings) unfinished
	elif settings.type == "tiledmodel" : 
		settings.numDims = 3 
		settings = parseTiledModel.parseTiledModel(settings)
	else :
		print("ERROR: Only simpledtiled or tiledmodel are allowed" )

	if settings.useAc4 : 
		settings = computeSupport(settings)

	var endInput : float = Time.get_datetime_dict_from_system()["second"]

	print("parse duration : " , endInput-startInput )
	
	return settings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
