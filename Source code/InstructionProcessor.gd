extends Control
class_name InstructionProcessor
@export_enum('Tokenizer', 'Parser', 'Interpreter') var StopAt:int = 2
@onready var Editor:TextEdit = $Panel/MarginContainer/VBoxContainer/VSplitContainer/CodeEdit
@onready var Display:Array[RichTextLabel] = [
	$Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer/Tokenizer/RichTextLabel,
	$Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer/Parser/RichTextLabel,
	$Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer/Interpreter/RichTextLabel
]
@onready var Tab:TabContainer = $Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer
@onready var Config:ConfigurationData = preload("res://Configurations/Config.tres")

var TokenizerObject:Tokenizer = Tokenizer.new()
var ParserObject:VertexParser = VertexParser.new()
var InterpreterObject:Interpreter = Interpreter.new()

func Run() -> void:
	# Tokenize
	var tokens = TokenizerObject.Tokenize(Editor.text)
	if tokens is Error:
		Display[0].append_text(str(tokens))
		Display[0].newline()
		Tab.current_tab = 0
		return
	else:
		var Parsed:String = ""
		for token:Token in tokens:
			Parsed += str(token) + ', '
			if token.Type == Token.TYPE.END_OF_LINE:
				Parsed += '\n'
		Display[0].append_text(str(Parsed))
		Display[0].newline()
		if StopAt == 0:
			Tab.current_tab = 0
			return
	# Parse
	var vertexes = ParserObject.Parse(tokens)
	if vertexes is Error:
		Display[1].append_text(str(vertexes))
		Display[1].newline()
		Tab.current_tab = 1
		return
	else:
		var Parsed:String = ""
		for vertex:Vertex in vertexes:
			Parsed += str(vertex) + '\n'
		Display[1].append_text(str(Parsed))
		Display[1].newline()
		if StopAt == 1:
			Tab.current_tab = 1
			return
	# Interprete
	Interpreter.Output = ''
	var output = InterpreterObject.Interprete(vertexes)
	Display[2].append_text(str(output))
	Display[2].newline()
	Tab.current_tab = 2

func _ready() -> void:
	Editor.text = Config.Code
	Tab.current_tab = StopAt
	var Highlighter:CodeHighlighter = CodeHighlighter.new()
	Highlighter.number_color = Color.LIGHT_GREEN
	Highlighter.symbol_color = Color.AQUA
	Highlighter.function_color = Color.CORNFLOWER_BLUE
	Highlighter.member_variable_color = Color.LIGHT_BLUE
	
	#for keyword in Tokenizer.MODIFIER_KEYWORDS:
		#Highlighter.keyword_colors[keyword] = Color.PURPLE
	for keyword in Tokenizer.DATA_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.FIREBRICK
	for keyword in Tokenizer.DATATYPE_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.FIREBRICK
	for keyword in Tokenizer.OPERATOR_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.FIREBRICK
	for keyword in Tokenizer.FLOWCONTROL_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.PURPLE
	for keyword in Tokenizer.DECISION_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.PURPLE
	for keyword in Tokenizer.LOOP_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.PURPLE
	for keyword in Tokenizer.INSTRUCTION_SET_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.CADET_BLUE
	for keyword in Tokenizer.FUNCTION_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.SEA_GREEN
	
	Highlighter.add_color_region('"', '"', Color.GREEN_YELLOW)
	Highlighter.add_color_region("'", "'", Color.GREEN_YELLOW)
	Highlighter.add_color_region('#', '', Color.DIM_GRAY, true)
	Editor.syntax_highlighter = Highlighter

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("Save"):
		Config.Code = Editor.text
		var State:int = ResourceSaver.save(Config, 'res://Configurations/Config.tres')
		if State == OK:
			Display[StopAt].append_text("Save Successful")
			Display[StopAt].newline()
		else:
			Display[StopAt].append_text("Save Failed")
			Display[StopAt].newline()

func _on_run_pressed() -> void:
	if Editor.text != '':
		Run()

func _on_pause_pressed() -> void:
	pass # Replace with function body.

func _on_stop_pressed() -> void:
	pass # Replace with function body.

func _on_clear_pressed() -> void:
	for x in Display:
		x.clear()
