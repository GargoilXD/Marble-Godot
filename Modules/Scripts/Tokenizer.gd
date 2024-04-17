class_name Tokenizer
#const MODIFIER_KEYWORDS:Array = ['Const', 'Static', 'Public', 'Private', 'Void']
const DATA_KEYWORDS:Array = ['true', 'false']#, 'null', 'self']
const DATATYPE_KEYWORDS:Array = ['Variant', 'Boolean', 'Integer', 'Float', 'String', 'List', 'Dictionary']#, 'Enumeration']
const OPERATOR_KEYWORDS:Array = ['not', 'and', 'or', 'in', 'is']#, 'extends']
const FLOWCONTROL_KEYWORDS:Array = ['Break', 'Continue', 'Return']
const DECISION_KEYWORDS:Array = ['if', 'else', 'elseif']#, 'Match', 'Case', 'Default']
const LOOP_KEYWORDS:Array = ['For', 'While']
const INSTRUCTION_SET_KEYWORDS:Array = ['Class', 'Function']
const FUNCTION_KEYWORDS:Array = ['Assert', 'Print', 'Range']
const LETTERS:Array = ['q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m','_']
const NUMBERS:Array = ['1','2','3','4','5','6','7','8','9','0']
const OPERATORS:Array = ['!','+','-','*','/','^','%','=','<','>',':','.','&','|']
static var Code:String = ""
var Index:int
var Line:int
var Character:String
var Tokens:Array[Token] = []
var Positioner:TokenPositioner = TokenPositioner.new()

class TokenPositioner:
	var StartPoint:int
	var EndPoint:int
	var StartLine:int
	var EndLine:int
	
	func _init():
		Reset()

	func Reset() -> void:
		StartPoint = 0
		EndPoint = 0
		StartLine = 0
		EndLine = 0
	
	static func DropPoint(index:int, line:int) -> TokenPosition:
		return TokenPosition.new(index, index, line, line)
	
	func SetStart(index:int, line:int) -> void:
		StartPoint = index
		StartLine = line
	
	func SetEnd(index:int, line:int, character:String) -> TokenPosition:
		EndPoint = index - 1
		EndLine = line - 1 if character == '\n' else line
		return TokenPosition.new(StartPoint, EndPoint, StartLine, EndLine)

func SetNextCharacter() -> void:
	Index += 1
	assert(Index - Code.length() < 1)
	Character = Code[Index] if Index < Code.length() else ''
	if Character == '\n':
		Line += 1

func Tokenize(code:String):
	Code = code
	Error.Code = code
	Index = -1
	Line = 0
	Character = ''
	Tokens.clear()
	Positioner.Reset()
	SetNextCharacter()
	var Result = null
	while Character != '':
		if Character in [' ', '\t']:
			SetNextCharacter()
		elif Character.to_lower() in LETTERS:
			Result = MakeLetterToken()
		elif Character in ['"',"'"]:
			Result = MakeStringToken()
		elif Character in NUMBERS:
			Result = MakeNumberToken()
		elif Character in OPERATORS:
			Result = MakeOperatorToken()
		else:
			match Character:
				'$':
					if Tokens.is_empty():
						SetNextCharacter()
					else:
						var ErrorToken:Token = Tokens.pop_back()
						return Error.new(Error.TYPE.NONE, ErrorToken.Position, str(ErrorToken))
				'\n':
					Tokens.append(Token.new(Token.TYPE.END_OF_LINE, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				'#':
					IgnoreComment()
				',':
					Tokens.append(Token.new(Token.TYPE.COMMA, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				'{':
					Tokens.append(Token.new(Token.TYPE.LEFT_CURLY_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				'}':
					Tokens.append(Token.new(Token.TYPE.RIGHT_CURLY_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				'(':
					Tokens.append(Token.new(Token.TYPE.LEFT_CIRCLE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				')':
					Tokens.append(Token.new(Token.TYPE.RIGHT_CIRCLE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				'[':
					Tokens.append(Token.new(Token.TYPE.LEFT_SQUARE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				']':
					Tokens.append(Token.new(Token.TYPE.RIGHT_SQUARE_BRACKET, TokenPositioner.DropPoint(Index, Line)))
					SetNextCharacter()
				_: return Error.new(Error.TYPE.INVALID_CHARACTER, TokenPositioner.DropPoint(Index, Line), Character)
		if Result:
			if Result is Error:
				return Result
			elif Result is Token:
				Tokens.append(Result)
		Result = null
	Tokens.append(Token.new(Token.TYPE.END_OF_FILE, TokenPositioner.DropPoint(Index, Line)))
	return Tokens

func MakeNumberToken() -> DataToken:
	var Data:String = ""
	var Dot:int = 0
	Positioner.SetStart(Index, Line)
	while Character in NUMBERS + ['.']:
		if Character == '.':
			Dot += 1
		if Dot == 2:
			break
		Data += Character
		SetNextCharacter()
	if Dot == 1:
		return DataToken.new(DataToken.DATATYPE.FLOAT, Positioner.SetEnd(Index, Line, Character), float(Data))
	else:
		return DataToken.new(DataToken.DATATYPE.INTEGER, Positioner.SetEnd(Index, Line, Character), int(Data))

func MakeLetterToken() -> Token:
	var Data:String = ""
	Positioner.SetStart(Index, Line)
	while Character.to_lower() in LETTERS + NUMBERS:
		Data += Character
		SetNextCharacter()
	#if Data in MODIFIER_KEYWORDS:
		#match Data:
			#'Const': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.SetEnd(Index, Line, Character), Data)
			#'Static': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.SetEnd(Index, Line, Character), Data)
			#'Public': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.SetEnd(Index, Line, Character), Data)
			#'Private': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.SetEnd(Index, Line, Character), Data)
			#'Void': return KeywordToken.new(KeywordToken.KEYWORD.MODIFIER, Positioner.SetEnd(Index, Line, Character), Data)
	if Data in DATA_KEYWORDS:
		match Data:
			'true': return DataToken.new(DataToken.DATATYPE.BOOLEAN, Positioner.SetEnd(Index, Line, Character), true)
			'false': return DataToken.new(DataToken.DATATYPE.BOOLEAN, Positioner.SetEnd(Index, Line, Character), false)
			'null': return DataToken.new(DataToken.DATATYPE.VARIANT, Positioner.SetEnd(Index, Line, Character), null)
			'self': return DataToken.new(DataToken.DATATYPE.OBJECT, Positioner.SetEnd(Index, Line, Character), Data)
	elif Data in DATATYPE_KEYWORDS:
		match Data:
			'Variant': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.VARIANT)
			'Boolean': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.BOOLEAN)
			'Integer': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.INTEGER)
			'Float': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.FLOAT)
			'String': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.STRING)
			'List': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.LIST)
			'Dictionary': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.DICTIONARY)
			'Enumeration': return KeywordToken.new(KeywordToken.KEYWORD.DATATYPE, Positioner.SetEnd(Index, Line, Character), DataToken.DATATYPE.ENUMERATION)
	elif Data in OPERATOR_KEYWORDS:
		match Data:
			'not': return OperatorToken.new(OperatorToken.OPERATORTYPE.NOT, Positioner.SetEnd(Index, Line, Character))
			'and': return OperatorToken.new(OperatorToken.OPERATORTYPE.AND, Positioner.SetEnd(Index, Line, Character))
			'or': return OperatorToken.new(OperatorToken.OPERATORTYPE.OR, Positioner.SetEnd(Index, Line, Character))
			'in': return OperatorToken.new(OperatorToken.OPERATORTYPE.IN, Positioner.SetEnd(Index, Line, Character))
			'is': return OperatorToken.new(OperatorToken.OPERATORTYPE.IS, Positioner.SetEnd(Index, Line, Character))
			'extends': return OperatorToken.new(OperatorToken.OPERATORTYPE.EXTENDS, Positioner.SetEnd(Index, Line, Character))
	elif Data in FLOWCONTROL_KEYWORDS:
		match Data:
			'Break': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.SetEnd(Index, Line, Character), Data)
			'Continue': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.SetEnd(Index, Line, Character), Data)
			'Return': return KeywordToken.new(KeywordToken.KEYWORD.FLOWCONTROL, Positioner.SetEnd(Index, Line, Character), Data)
	elif Data in DECISION_KEYWORDS:
		match Data:
			'if': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.SetEnd(Index, Line, Character), Data)
			'else': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.SetEnd(Index, Line, Character), Data)
			'elseif': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.SetEnd(Index, Line, Character), Data)
			'Match': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.SetEnd(Index, Line, Character), Data)
			'Case': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.SetEnd(Index, Line, Character), Data)
			'Default': return KeywordToken.new(KeywordToken.KEYWORD.DECISION, Positioner.SetEnd(Index, Line, Character), Data)
	elif Data in LOOP_KEYWORDS:
		match Data:
			'For': return KeywordToken.new(KeywordToken.KEYWORD.LOOP, Positioner.SetEnd(Index, Line, Character), Data)
			'While': return KeywordToken.new(KeywordToken.KEYWORD.LOOP, Positioner.SetEnd(Index, Line, Character), Data)
	elif Data in INSTRUCTION_SET_KEYWORDS:
		match Data:
			'Class': return KeywordToken.new(KeywordToken.KEYWORD.INSTRUCTION_SET, Positioner.SetEnd(Index, Line, Character), Data)
			'Function': return KeywordToken.new(KeywordToken.KEYWORD.INSTRUCTION_SET, Positioner.SetEnd(Index, Line, Character), Data)
	elif Data in FUNCTION_KEYWORDS:
		match Data:
			'Assert': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.SetEnd(Index, Line, Character), Data)
			'Print': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.SetEnd(Index, Line, Character), Data)
			'Range': return KeywordToken.new(KeywordToken.KEYWORD.FUNCTION, Positioner.SetEnd(Index, Line, Character), Data)
	return DataToken.new(DataToken.DATATYPE.IDENTIFIER, Positioner.SetEnd(Index, Line, Character), Data)

func MakeOperatorToken():
	var Data:String = ""
	var Count:int = 0
	Positioner.SetStart(Index, Line)
	while Character in OPERATORS:
		Data += Character
		Count += 1
		SetNextCharacter()
		if Count == 3:
			break
	match Data:
		'.': return OperatorToken.new(OperatorToken.OPERATORTYPE.DOT, Positioner.SetEnd(Index, Line, Character))
		'!': return OperatorToken.new(OperatorToken.OPERATORTYPE.NOT, Positioner.SetEnd(Index, Line, Character))
		'+': return OperatorToken.new(OperatorToken.OPERATORTYPE.ADD, Positioner.SetEnd(Index, Line, Character))
		'-': return OperatorToken.new(OperatorToken.OPERATORTYPE.SUBTRACT, Positioner.SetEnd(Index, Line, Character))
		'*': return OperatorToken.new(OperatorToken.OPERATORTYPE.MULTIPLY, Positioner.SetEnd(Index, Line, Character))
		'/': return OperatorToken.new(OperatorToken.OPERATORTYPE.DIVIDE, Positioner.SetEnd(Index, Line, Character))
		'^': return OperatorToken.new(OperatorToken.OPERATORTYPE.EXPONENT, Positioner.SetEnd(Index, Line, Character))
		'%': return OperatorToken.new(OperatorToken.OPERATORTYPE.MODOLUS, Positioner.SetEnd(Index, Line, Character))
		'=': return OperatorToken.new(OperatorToken.OPERATORTYPE.ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'<': return OperatorToken.new(OperatorToken.OPERATORTYPE.LESSER_THAN, Positioner.SetEnd(Index, Line, Character))
		'>': return OperatorToken.new(OperatorToken.OPERATORTYPE.GREATER_THAN, Positioner.SetEnd(Index, Line, Character))
		':': return OperatorToken.new(OperatorToken.OPERATORTYPE.COLON, Positioner.SetEnd(Index, Line, Character))
		'&': return OperatorToken.new(OperatorToken.OPERATORTYPE.BITWISE_AND, Positioner.SetEnd(Index, Line, Character))
		'|': return OperatorToken.new(OperatorToken.OPERATORTYPE.BITWISE_OR, Positioner.SetEnd(Index, Line, Character))
		'!=': return OperatorToken.new(OperatorToken.OPERATORTYPE.NOT_EQUALS, Positioner.SetEnd(Index, Line, Character))
		'+=': return OperatorToken.new(OperatorToken.OPERATORTYPE.ADD_AND_ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'-=': return OperatorToken.new(OperatorToken.OPERATORTYPE.SUBTRACT_AND_ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'*=': return OperatorToken.new(OperatorToken.OPERATORTYPE.MULTIPLY_AND_ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'/=': return OperatorToken.new(OperatorToken.OPERATORTYPE.DIVIDE_AND_ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'^=': return OperatorToken.new(OperatorToken.OPERATORTYPE.EXPONENT_AND_ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'%=': return OperatorToken.new(OperatorToken.OPERATORTYPE.MODOLUS_AND_ASSIGN, Positioner.SetEnd(Index, Line, Character))
		'==': return OperatorToken.new(OperatorToken.OPERATORTYPE.EQUALS, Positioner.SetEnd(Index, Line, Character))
		'<=': return OperatorToken.new(OperatorToken.OPERATORTYPE.LESSER_THAN_OR_EQUALS, Positioner.SetEnd(Index, Line, Character))
		'>=': return OperatorToken.new(OperatorToken.OPERATORTYPE.GREATER_THAN_OR_EQUALS, Positioner.SetEnd(Index, Line, Character))
		_: return Error.new(Error.TYPE.UNIDENTIFIED_OPERATOR, Positioner.SetEnd(Index, Line, Character), Data)

func MakeStringToken():
	var Encloser:String = Character
	var Data:String = ""
	Positioner.SetStart(Index, Line)
	SetNextCharacter()
	while not (Character in [Encloser, '']):
		Data += Character
		SetNextCharacter()
	if Character == '':
		return Error.new(Error.TYPE.INCOMPLETE_STRING, TokenPositioner.DropPoint(Positioner.StartPoint, Positioner.EndLine), '')
	SetNextCharacter()
	return DataToken.new(DataToken.DATATYPE.STRING, Positioner.SetEnd(Index, Line, Character), Data)

func IgnoreComment() -> void:
	SetNextCharacter()
	while not (Character in ['#', '\n', '']):
		SetNextCharacter()
	if Character == '#':
		SetNextCharacter()
