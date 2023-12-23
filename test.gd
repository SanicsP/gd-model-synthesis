extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var parse_input_classe = preload("res://scripts/ParseInput/parseInput.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	var parser = XMLParser.new()
	
	parser.open("sample.xml")
	
	var settings = null
	
	while parser.read() == OK :
		if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "tiledmodel" :
			settings = ParseSampleInput.parseInput(parser , 100)
			print(settings)
	
	print("name : " , settings.name_)
	
	print("width , height , length : " , settings.size)
	
	#print("transition {trans}".format({"trans" : settings.transition[2]}))
	
	print("queue test")
	var synth : Synthetizer = Synthetizer.new(settings , 5)
	print("synthetizing...")
	synth.synthesize(5)
	print("ok")
	synth.printModel()
	
	
	OutputGenerator.GenerateTiledModel(settings , synth.model , "output/test.txt")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
