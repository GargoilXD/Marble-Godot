extends Control
class_name InstructionProcessor
enum DISPLAY{
	TOKENIZER,
	PARSER,
	INTERPRETER
}
@export var Save_data:SaveData = preload("res://Configurations/Save_data.tres")
@onready var Editor:CodeEdit = $Panel/MarginContainer/VBoxContainer/VSplitContainer/CodeEdit
@onready var Tab:TabContainer = $Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer
@onready var Option_button:OptionButton = $Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var Displays:Array[RichTextLabel] = [
	$Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer/Tokenizer/RichTextLabel,
	$Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer/Parser/RichTextLabel,
	$Panel/MarginContainer/VBoxContainer/VSplitContainer/VBoxContainer/TabContainer/Interpreter/RichTextLabel
]
var Tokenizer_object:Tokenizer = Tokenizer.new()
var Parser_object:Parser = Parser.new()
var Interpreter_object:Interpreter = Interpreter.new()
var Stop_at:DISPLAY
@onready var accept_dialog:AcceptDialog = $AcceptDialog

func Run() -> void:
	#region Tokenize
	var tokens = Tokenizer_object.Tokenize(Editor.text)
	if tokens is Error:
		Display_data(DISPLAY.TOKENIZER, tokens)
		Tab.current_tab = DISPLAY.TOKENIZER
		return
	else:
		var output:String = ''
		for token:Token in tokens:
			output += str(token) + ', '
			if token.Type == Token.TYPE.END_OF_LINE:
				output += '\n'
		Display_data(DISPLAY.TOKENIZER, output.trim_suffix(', '))
		if Stop_at == DISPLAY.TOKENIZER:
			Tab.current_tab = DISPLAY.TOKENIZER
			return
	#endregion
	#region Parse
	var vertexes = Parser_object.Parse(tokens)
	if vertexes is Error:
		Display_data(DISPLAY.PARSER, vertexes)
		Tab.current_tab = DISPLAY.PARSER
		return
	else:
		var output:String = ''
		for vertex:Vertex in vertexes:
			output += str(vertex) + '\n'
		Display_data(DISPLAY.PARSER, output)
		if Stop_at == DISPLAY.PARSER:
			Tab.current_tab = DISPLAY.PARSER
			return
	#endregion
	#region Interprete
	Interpreter.Output = ''
	var Output:String = ''
	var interpreter_output:InterpreterOutput = await Interpreter_object.Interprete(vertexes)
	match interpreter_output.Breaker:
		InterpreterOutput.BREAKER.NONE:
			Output = str(interpreter_output.Output)
		InterpreterOutput.BREAKER.BREAK, InterpreterOutput.BREAKER.CONTINUE, InterpreterOutput.BREAKER.RETURN:
			breakpoint
		InterpreterOutput.BREAKER.ERROR:
			Output = str(interpreter_output.Error_object)
	Display_data(DISPLAY.INTERPRETER, Output)
	Tab.current_tab = DISPLAY.INTERPRETER
	#endregion

func Display_data(display:DISPLAY, data) -> void:
	Displays[display].append_text(str(data))
	Displays[display].newline()

func _ready() -> void:
	Editor.text = Save_data.Code
	Stop_at = Save_data.Stop_at
	Tab.current_tab = Stop_at
	Option_button.select(Stop_at)
	Interpreter_object.PopUp_input = accept_dialog
	#region Highlighter
	var Highlighter:CodeHighlighter = CodeHighlighter.new()
	Highlighter.number_color = Color.LIGHT_GREEN
	Highlighter.symbol_color = Color.AQUA
	Highlighter.function_color = Color.CORNFLOWER_BLUE
	Highlighter.member_variable_color = Color.LIGHT_BLUE
	
	for keyword in Tokenizer.MODIFIER_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.CRIMSON
	for keyword in Tokenizer.DATA_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.INDIAN_RED
	for keyword in Tokenizer.DATATYPE_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.FIREBRICK
	for keyword in Tokenizer.OPERATOR_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.FIREBRICK
	for keyword in Tokenizer.FLOWCONTROL_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.PURPLE
	for keyword in Tokenizer.DECISION_KEYWORDS:
		Highlighter.keyword_colors[keyword] = Color.YELLOW
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
	#endregion

func _input(event:InputEvent) -> void:
	if event.is_action_pressed('Save'):
		Save_data.Code = Editor.text
		Save_data.Stop_at = Stop_at
		var State:int = ResourceSaver.save(Save_data, 'res://Configurations/Save_data.tres')
		if State == OK:
			Displays[Stop_at].append_text('Save Successful')
			Displays[Stop_at].newline()
		else:
			Displays[Stop_at].append_text('Save Failed')
			Displays[Stop_at].newline()

func _on_run_pressed() -> void:
	if !Editor.text.is_empty():
		Error.Code = Editor.text
		Run()

func _on_pause_pressed() -> void:
	pass # Replace with function body.

func _on_stop_pressed() -> void:
	pass # Replace with function body.

func _on_clear_pressed() -> void:
	for Display:RichTextLabel in Displays:
		Display.clear()

func _on_option_button_item_selected(index:int) -> void:
	Stop_at = index as DISPLAY
	Tab.current_tab = Stop_at
