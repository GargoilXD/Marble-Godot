class_name Error
enum TYPE{
	NONE,
	INVALID_CHARACTER,
	UNIDENTIFIED_OPERATOR,
	INCOMPLETE_STRING,
	EXPECTED_OPERAND,
	UNEXPECTED_OPERAND,
	EXPECTED_TOKEN,
	UNDEFINED_IDENTIFIER,
	DATATYPE_MISMATCH,
	ALREADY_DEFINED_IDENTIFIER,
	DIVISION_BY_ZERO,
	UNEXPECTED_TOKEN,
	EXPECTED_IDENTIFIER,
	UNINITIALIZED_IDENTIFIER,
	BREAK,
	CONTINUE,
	RETURN,
	INCOMPATIBLE_TYPES,
	ASSERTION_FAILED
}
static var Code:String = ""
var Type:int = TYPE.NONE
var Details:String
var Position:TokenPosition
var Data:String

func _init(_type, _position:TokenPosition, _details:String = ''):
	Type = _type
	Position = _position
	Details = _details
	

func DrawPosition():
	if !Position:
		return ''
	var Start:int = Position.StartPoint
	var End:int = Position.EndPoint - Position.StartPoint
	var LineNumber:int = 0
	var Lines:Array[String] = []
	var Line:String = ''
	var FullLenght:String = ''
	for Character:String in Code + '\n':
		if LineNumber < Position.StartLine:
			Start -= 1
		if LineNumber >= Position.StartLine and LineNumber <= Position.EndLine:
			FullLenght += Character
			Line += Character
			if Character == '\n':
				Lines.append(Line)
				Line = ''
		elif LineNumber > Position.EndLine:
			break
		if Character == '\n':
			LineNumber += 1
	End += Start
	var Index:int = 0
	var LineIndex:int = 0
	var LineSize:int = Lines[LineIndex].length()
	while Index <= Position.EndPoint and LineIndex < Lines.size():
		if Index > End:
			break
		if Index == LineSize:
			LineIndex += 1
			LineSize += Lines[LineIndex].length()
		if Index < Start:
			match  FullLenght[Index]:
				'\t': Lines[LineIndex] += '    '
				'\n': Lines[LineIndex] += '\n'
				_: Lines[LineIndex] += ' '
		elif Index >= Start and Index <= End:
			match  FullLenght[Index]:
				'\n': Lines[LineIndex] += '^\n'
				'\t': Lines[LineIndex] += '^^^^'
				_: Lines[LineIndex] += '^'
		Index += 1
	var output:String = ''
	for line in Lines:
		output += line
	return output

func _to_string():
	return TYPE.keys()[Type] + ('' if Details.is_empty() else ' : ' + Details) + '\n' + DrawPosition()
