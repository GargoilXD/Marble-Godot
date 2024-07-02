class_name Tokenizer
static var Code:String = ''
const MODIFIER_KEYWORDS:Array = ['Const', 'Static', 'Public', 'Private', 'Void']
const DATA_KEYWORDS:Array = ['true', 'false', 'null', 'self']
const DATATYPE_KEYWORDS:Array = ['Variant', 'Boolean', 'Integer', 'Float', 'String', 'List', 'Dictionary', 'Enumeration', 'Object']
const OPERATOR_KEYWORDS:Array = ['not', 'and', 'or', 'in', 'is', 'extends']
const FLOWCONTROL_KEYWORDS:Array = ['Break', 'Continue', 'Return', 'Breakpoint']
const DECISION_KEYWORDS:Array = ['if', 'else', 'elseif', 'Match', 'Case', 'Default']
const LOOP_KEYWORDS:Array = ['For', 'While']
const INSTRUCTION_SET_KEYWORDS:Array = ['Class', 'Function']
const FUNCTION_KEYWORDS:Array = ['Assert', 'Print', 'Range', 'Random', 'Input']
const LETTERS:Array = ['q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m','_']
const NUMBERS:Array = ['1','2','3','4','5','6','7','8','9','0']
const OPERATOR_CHARACTERS:Array = ['!','+','-','*','/','^','%','=','<','>',':','.','&','|']
var Index:int
var Line:int
var Character:String
var Tokens:Array[Token] = []
var Positioner:TokenPositioner = TokenPositioner.new()

class TokenPositioner:
	var Start_point:int
	var End_point:int
	var Start_line:int
	var End_line:int
	
	func _init() -> void:
		reset()

	func reset() -> void:
		Start_point = 0
		End_point = 0
		Start_line = 0
		End_line = 0
	
	static func DropPoint(index:int, line:int) -> TokenPosition:
		return TokenPosition.new(index, index, line, line)
	
	func set_start(index:int, line:int) -> void:
		Start_point = index
		Start_line = line
	
	func set_end(index:int, line:int, character:String) -> TokenPosition:
		End_point = index - 1
		End_line = (line - 1) if character == '\n' else line
		return TokenPosition.new(Start_point, End_point, Start_line, End_line)

func Next_character() -> void:
	Index += 1
	Character = Code[Index] if Index < Code.length() else ''
	if Character == '\n': Line += 1

func Tokenize(code:String):
	Code = code
	Index = -1
	Line = 0
	Character = ''
	Tokens.clear()
	Positioner.reset()
	Next_character()
	while Character != '':
		if Character in [' ', '\t']:
			Next_character()
		elif Character.to_lower() in LETTERS:
			Tokens.append(Make_letter_token())
		elif Character in ['"', "'"]:
			var Result = Make_string_token()
			if Result is Error:
				return Result
			else:
				Tokens.append(Result)
		elif Character in NUMBERS:
			Tokens.append(Make_number_token())
		elif Character in OPERATOR_CHARACTERS:
			var Result = Make_operator_token()
			if Result is Error:
				return Result
			else:
				Tokens.append(Result)
		else:
			match Character:
				'$':
					if Tokens.is_empty():
						Next_character()
					else:
						var ErrorToken:Token = Tokens.pop_back()
						return Error.new(Error.TYPE.MESSAGE, ErrorToken.Position, str(ErrorToken))
				'\n':
					Tokens.append(Token.new(Token.TYPE.END_OF_LINE, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				'#':
					Ignore_comment()
				',':
					Tokens.append(Token.new(Token.TYPE.COMMA, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				'{':
					Tokens.append(Token.new(Token.TYPE.LEFT_CURLY_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				'}':
					Tokens.append(Token.new(Token.TYPE.RIGHT_CURLY_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				'(':
					Tokens.append(Token.new(Token.TYPE.LEFT_CIRCLE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				')':
					Tokens.append(Token.new(Token.TYPE.RIGHT_CIRCLE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				'[':
					Tokens.append(Token.new(Token.TYPE.LEFT_SQUARE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				']':
					Tokens.append(Token.new(Token.TYPE.RIGHT_SQUARE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					Next_character()
				_: return Error.new(Error.TYPE.INVALID_CHARACTER, TokenPositioner.DropPoint(Index, Line), Character)
	Tokens.append(Token.new(Token.TYPE.END_OF_FILE, TokenPositioner.DropPoint(Index, Line)))
	return Tokens

func Make_number_token() -> DataToken:
	var data:String = ""
	var dot:int = 0
	Positioner.set_start(Index, Line)
	while Character in NUMBERS + ['.']:
		if Character == '.':
			dot += 1
		if dot == 2:
			break
		data += Character
		Next_character()
	if dot == 1:
		return DataToken.new(DataToken.DATATYPE.FLOAT, Positioner.set_end(Index, Line, Character), float(data))
	else:
		return DataToken.new(DataToken.DATATYPE.INTEGER, Positioner.set_end(Index, Line, Character), int(data))

func Make_letter_token() -> Token:
	var data:String = ''
	Positioner.set_start(Index, Line)
	while Character.to_lower() in LETTERS + NUMBERS:
		data += Character
		Next_character()
	if data in MODIFIER_KEYWORDS:
		match data:
			'Const': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.set_end(Index, Line, Character), data)
			'Static': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.set_end(Index, Line, Character), data)
			'Public': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.set_end(Index, Line, Character), data)
			'Private': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.set_end(Index, Line, Character), data)
			'Void': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.set_end(Index, Line, Character), data)
	elif data in DATA_KEYWORDS:
		match data:
			'true': return DataToken.new(DataToken.DATATYPE.BOOLEAN, Positioner.set_end(Index, Line, Character), true)
			'false': return DataToken.new(DataToken.DATATYPE.BOOLEAN, Positioner.set_end(Index, Line, Character), false)
			'null': return DataToken.new(DataToken.DATATYPE.VARIANT, Positioner.set_end(Index, Line, Character), null)
			'self': return DataToken.new(DataToken.DATATYPE.OBJECT, Positioner.set_end(Index, Line, Character), data)
	elif data in DATATYPE_KEYWORDS:
		match data:
			'Variant': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.VARIANT)
			'Boolean': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.BOOLEAN)
			'Integer': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.INTEGER)
			'Float': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.FLOAT)
			'String': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.STRING)
			'List': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.LIST)
			'Dictionary': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.DICTIONARY)
			'Enumeration': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.ENUMERATION)
			'Object': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.set_end(Index, Line, Character), DataToken.DATATYPE.OBJECT)
	elif data in OPERATOR_KEYWORDS:
		match data:
			'not': return OperatorToken.new(OperatorToken.OPERATORTYPE.NOT, Positioner.set_end(Index, Line, Character))
			'and': return OperatorToken.new(OperatorToken.OPERATORTYPE.AND, Positioner.set_end(Index, Line, Character))
			'or': return OperatorToken.new(OperatorToken.OPERATORTYPE.OR, Positioner.set_end(Index, Line, Character))
			'in': return OperatorToken.new(OperatorToken.OPERATORTYPE.IN, Positioner.set_end(Index, Line, Character))
			'is': return OperatorToken.new(OperatorToken.OPERATORTYPE.IS, Positioner.set_end(Index, Line, Character))
			'extends': return OperatorToken.new(OperatorToken.OPERATORTYPE.EXTENDS, Positioner.set_end(Index, Line, Character))
	elif data in FLOWCONTROL_KEYWORDS:
		match data:
			'Break': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.set_end(Index, Line, Character), data)
			'Continue': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.set_end(Index, Line, Character), data)
			'Return': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.set_end(Index, Line, Character), data)
			'Breakpoint': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.set_end(Index, Line, Character), data)
	elif data in DECISION_KEYWORDS:
		match data:
			'if': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.set_end(Index, Line, Character), data)
			'else': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.set_end(Index, Line, Character), data)
			'elseif': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.set_end(Index, Line, Character), data)
			'Match': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.set_end(Index, Line, Character), data)
			'Case': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.set_end(Index, Line, Character), data)
			'Default': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.set_end(Index, Line, Character), data)
	elif data in LOOP_KEYWORDS:
		match data:
			'For': return KeywordToken.new(KeywordToken.KEYWORD.LOOP, Positioner.set_end(Index, Line, Character), data)
			'While': return KeywordToken.new(KeywordToken.KEYWORD.LOOP, Positioner.set_end(Index, Line, Character), data)
	elif data in INSTRUCTION_SET_KEYWORDS:
		match data:
			'Class': return KeywordToken.new(KeywordToken.KEYWORD.INSTRUCTION_SET, Positioner.set_end(Index, Line, Character), data)
			'Function': return KeywordToken.new(KeywordToken.KEYWORD.INSTRUCTION_SET, Positioner.set_end(Index, Line, Character), data)
	elif data in FUNCTION_KEYWORDS:
		match data:
			'Assert': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.set_end(Index, Line, Character), data)
			'Print': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.set_end(Index, Line, Character), data)
			'Range': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.set_end(Index, Line, Character), data)
			'Random': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.set_end(Index, Line, Character), data)
			'Input': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.set_end(Index, Line, Character), data)
	return DataToken.new(DataToken.DATATYPE.IDENTIFIER, Positioner.set_end(Index, Line, Character), data)

func Make_operator_token():
	var data:String = ""
	var count:int = 0
	Positioner.set_start(Index, Line)
	while Character in OPERATOR_CHARACTERS:
		data += Character
		count += 1
		Next_character()
		if count == 3: break
	match data:
		'.': return OperatorToken.new(OperatorToken.OPERATORTYPE.DOT, Positioner.set_end(Index, Line, Character))
		'!': return OperatorToken.new(OperatorToken.OPERATORTYPE.NOT, Positioner.set_end(Index, Line, Character))
		'+': return OperatorToken.new(OperatorToken.OPERATORTYPE.ADD, Positioner.set_end(Index, Line, Character))
		'-': return OperatorToken.new(OperatorToken.OPERATORTYPE.SUBTRACT, Positioner.set_end(Index, Line, Character))
		'*': return OperatorToken.new(OperatorToken.OPERATORTYPE.MULTIPLY, Positioner.set_end(Index, Line, Character))
		'/': return OperatorToken.new(OperatorToken.OPERATORTYPE.DIVIDE, Positioner.set_end(Index, Line, Character))
		'^': return OperatorToken.new(OperatorToken.OPERATORTYPE.EXPONENT, Positioner.set_end(Index, Line, Character))
		'%': return OperatorToken.new(OperatorToken.OPERATORTYPE.MODOLUS, Positioner.set_end(Index, Line, Character))
		'=': return OperatorToken.new(OperatorToken.OPERATORTYPE.ASSIGN, Positioner.set_end(Index, Line, Character))
		'<': return OperatorToken.new(OperatorToken.OPERATORTYPE.LESSER_THAN, Positioner.set_end(Index, Line, Character))
		'>': return OperatorToken.new(OperatorToken.OPERATORTYPE.GREATER_THAN, Positioner.set_end(Index, Line, Character))
		':': return OperatorToken.new(OperatorToken.OPERATORTYPE.COLON, Positioner.set_end(Index, Line, Character))
		'&': return OperatorToken.new(OperatorToken.OPERATORTYPE.BITWISE_AND, Positioner.set_end(Index, Line, Character))
		'|': return OperatorToken.new(OperatorToken.OPERATORTYPE.BITWISE_OR, Positioner.set_end(Index, Line, Character))
		'!=': return OperatorToken.new(OperatorToken.OPERATORTYPE.NOT_EQUALS, Positioner.set_end(Index, Line, Character))
		'+=': return OperatorToken.new(OperatorToken.OPERATORTYPE.ADD_AND_ASSIGN, Positioner.set_end(Index, Line, Character))
		'-=': return OperatorToken.new(OperatorToken.OPERATORTYPE.SUBTRACT_AND_ASSIGN, Positioner.set_end(Index, Line, Character))
		'*=': return OperatorToken.new(OperatorToken.OPERATORTYPE.MULTIPLY_AND_ASSIGN, Positioner.set_end(Index, Line, Character))
		'/=': return OperatorToken.new(OperatorToken.OPERATORTYPE.DIVIDE_AND_ASSIGN, Positioner.set_end(Index, Line, Character))
		'^=': return OperatorToken.new(OperatorToken.OPERATORTYPE.EXPONENT_AND_ASSIGN, Positioner.set_end(Index, Line, Character))
		'%=': return OperatorToken.new(OperatorToken.OPERATORTYPE.MODOLUS_AND_ASSIGN, Positioner.set_end(Index, Line, Character))
		'==': return OperatorToken.new(OperatorToken.OPERATORTYPE.EQUALS, Positioner.set_end(Index, Line, Character))
		'<=': return OperatorToken.new(OperatorToken.OPERATORTYPE.LESSER_THAN_OR_EQUALS, Positioner.set_end(Index, Line, Character))
		'>=': return OperatorToken.new(OperatorToken.OPERATORTYPE.GREATER_THAN_OR_EQUALS, Positioner.set_end(Index, Line, Character))
		_: return Error.new(Error.TYPE.UNIDENTIFIED_OPERATOR, Positioner.set_end(Index, Line, Character), data)

func Make_string_token():
	var encloser:String = Character
	var data:String = ""
	Positioner.set_start(Index, Line)
	Next_character()
	while !(Character in [encloser, '']):
		data += Character
		Next_character()
	if Character == '': return Error.new(Error.TYPE.INCOMPLETE_STRING, TokenPositioner.DropPoint(Positioner.Start_point, Positioner.End_line), '')
	Next_character()
	return DataToken.new(DataToken.DATATYPE.STRING, Positioner.set_end(Index, Line, Character), data)

func Ignore_comment() -> void:
	Next_character()
	while !(Character in ['#', '\n', '']): Next_character()
	if Character == '#': Next_character()
