extends Spatial




export var modelSize : Vector3 = Vector3.ZERO
export var tileSize : int = 0
export var model_name : String = ""

func parseModel() :
	var model_node = $model
	var model_dict : Dictionary = {}
	for tile in model_node.get_children()  :
		var pos : Vector3 = tile.transform.origin
		var key : Vector3 = Vector3(pos.x/tileSize , pos.y/tileSize , pos.z/tileSize)
		model_dict[key] = tile.id
	
	var model : Array = utils.make3dArray(modelSize.x , modelSize.z,  modelSize.y , 0)
	
	for x in modelSize.x :
		for y in modelSize.y : 
			for z in modelSize.z :
				if model_dict.has(Vector3(x,y,modelSize.z - z-1)) : 
					model[x][z][y] = model_dict[Vector3(x,y,modelSize.z-z-1)] + 1
				else : 
					model[x][z][y] = 0
	return model

func parseGridMap() : 
	var model_grid : GridMap = $input_model
	var model : Array = utils.make3dArray(modelSize.x , modelSize.z , modelSize.y , 0)
	
	for x in modelSize.x :
		for y in modelSize.y : 
			for z in modelSize.z :
				if model_grid.get_cell_item(x,y,z) != -1:
					model[x][z][y] = model_grid.get_cell_item(x,y,z) + 1
				else : 
					model[x][z][y] = 0
	return model
	

func generate_model_uwu(settings : InputSettings , model) :
	var tiles_type : Array = []
	var output_model = $output_model
	
	tiles_type.resize(settings.numLabels-1)
	for i in settings.numLabels - 1 :
		var path = "res://3d_models/" + model_name + "/tiles/tile"+str(i)+ ".tscn"
		tiles_type[i] = load(path)
	for x in settings.size[0] : 
		for y in settings.size[1] : 
			for z in settings.size[2] :
				if model[x][y][z] - 1 > 0 : 
					output_model.add_child(tiles_type[model[x][y][z]-1].instance())
				else :
					output_model.add_child(Spatial.new())					
				var child : Spatial = output_model.get_child(output_model.get_child_count()-1)
				child.transform.origin = Vector3(x*tileSize,z*tileSize,y*tileSize)
	.get_child(0).queue_free()

func generate_model(settings : InputSettings , model : Array) :
	var output_model : GridMap = $output_model
	for x in settings.size[0] : 
		for y in settings.size[1] : 
			for z in settings.size[2] :
				var item : int = model[x][y][z] - 1 
				if  item > 0 : 
					output_model.set_cell_item(x,z,y,item)
				else : 
					output_model.set_cell_item(x,z,y,-1)
	$input_model.queue_free()
	
func _ready():
	
	modelSize.y += 1
	
	var example_model = parseGridMap()
	
	var example_settings : InputSettings = InputSettings.new()
	
	example_settings.size.resize(3)
	
	example_settings.size[0] = int(modelSize.x)
	example_settings.size[1] = int(modelSize.z)
	example_settings.size[2] = int(modelSize.y)
	
	OutputGenerator.GenerateTiledModel(example_settings , example_model , "samples/backrooms.txt")
	
	
	var parser = XMLParser.new()
	
	parser.open("sample.xml")
	
	var settings = InputSettings.new()
	
	settings.useAc4 = true
	
	while parser.read() == OK :
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "tiledmodel" :
			settings = ParseSampleInput.parseInput(parser , 100)
			print(settings)
	
	print("name : " , settings.name_)
	
	print("width , height , length : " , settings.size)
	
	print("transition {trans}".format({"trans" : settings.transition[2]}))
	
	
	var synth : Synthetizer = Synthetizer.new(settings , 5)
	
	print("synthetizing...")
	
	synth.synthesize(5)
	print("end")
	OutputGenerator.GenerateTiledModel(settings , synth.model , "output/backrooms.txt")
	generate_model(settings , synth.model)
	
	pass # Replace with function body.
