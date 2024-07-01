extends Parser
class_name VertexParser
const PRECEDENCE:Array = [
	[OperatorToken.OPERATORTYPE.DOT],
	[OperatorToken.OPERATORTYPE.IS, OperatorToken.OPERATORTYPE.EXTENDS],
	[OperatorToken.OPERATORTYPE.EXPONENT],
	[OperatorToken.OPERATORTYPE.MODOLUS],
	[OperatorToken.OPERATORTYPE.MULTIPLY, OperatorToken.OPERATORTYPE.DIVIDE],
	[OperatorToken.OPERATORTYPE.ADD, OperatorToken.OPERATORTYPE.SUBTRACT],
	[OperatorToken.OPERATORTYPE.IN],
	[OperatorToken.OPERATORTYPE.EQUALS, OperatorToken.OPERATORTYPE.NOT_EQUALS, OperatorToken.OPERATORTYPE.LESSER_THAN, OperatorToken.OPERATORTYPE.LESSER_THAN_OR_EQUALS, OperatorToken.OPERATORTYPE.GREATER_THAN, OperatorToken.OPERATORTYPE.GREATER_THAN_OR_EQUALS],
	[OperatorToken.OPERATORTYPE.AND, OperatorToken.OPERATORTYPE.OR],
	[OperatorToken.OPERATORTYPE.COLON],
	[OperatorToken.OPERATORTYPE.ASSIGN, OperatorToken.OPERATORTYPE.ADD_AND_ASSIGN, OperatorToken.OPERATORTYPE.SUBTRACT_AND_ASSIGN, OperatorToken.OPERATORTYPE.MULTIPLY_AND_ASSIGN, OperatorToken.OPERATORTYPE.DIVIDE_AND_ASSIGN, OperatorToken.OPERATORTYPE.EXPONENT_AND_ASSIGN, OperatorToken.OPERATORTYPE.MODOLUS_AND_ASSIGN],
]
var GetExpression:Callable = func () : return GetBinaryVertex(
								func () : return GetBinaryVertex(
									func () : return GetBinaryVertex(
										func () : return GetBinaryVertex(
											func () : return GetBinaryVertex(
												func () : return GetBinaryVertex(
													func () : return GetBinaryVertex(
														func () : return GetBinaryVertex(
															func () : return GetBinaryVertex(
																func () : return GetBinaryVertex(
																	func () : return GetBinaryVertex(
																		func () : return GetBinaryVertex(
																			GetUnaryVertex,
																		PRECEDENCE[0]),
																	PRECEDENCE[1]),
																PRECEDENCE[2]),
															PRECEDENCE[3]),
														PRECEDENCE[4]),
													PRECEDENCE[5]),
												PRECEDENCE[6]),
											PRECEDENCE[7]),
										PRECEDENCE[8]),
									PRECEDENCE[9]),
								PRECEDENCE[10]))

func GetDataBracketVertex():
	var Helper:Callable = func (encloser):
		while CurrentToken.Type == Token.TYPE.END_OF_LINE: SetNextToken()
		if CurrentToken.Type == encloser + 1: return true
		return false
	var Encloser:int = CurrentToken.Type
	var Position:TokenPosition = CurrentToken.Position
	var Data:Array = []
	SetNextToken()
	while CurrentToken.Type != Token.TYPE.COMMA:
		if Helper.call(Encloser):
			break
		var Result = GetExpression.call()
		if Result is Error:
			return Result
		Data.append(Result)
		if Helper.call(Encloser):
			break
		if CurrentToken.Type == Token.TYPE.COMMA:
			SetNextToken()
		else:
			return Error.new(Error.TYPE.EXPECTED_TOKEN, CurrentToken.Position, '","')
	if CurrentToken.Type == Encloser + 1:
		Position.extend(CurrentToken.Position)
		SetNextToken()
		match Encloser:
			Token.TYPE.LEFT_CURLY_BRACKET:
				return DataVertex.FromToken(DataToken.new(DataToken.DATATYPE.DICTIONARY, Position, Data))
			Token.TYPE.LEFT_SQUARE_BRACKET:
				return DataVertex.FromToken(DataToken.new(DataToken.DATATYPE.LIST, Position, Data))
			Token.TYPE.LEFT_CIRCLE_BRACKET:
				return DataVertex.FromToken(DataToken.new(DataToken.DATATYPE.PARAMETER, Position, Data))
			
	else:
		return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position)

func GetInstructionsVertex():
	var Helper:Callable = func ():
		while CurrentToken.Type == Token.TYPE.END_OF_LINE: SetNextToken()
		if CurrentToken.Type == Token.TYPE.RIGHT_CURLY_BRACKET: return true
		return false
	var Position:TokenPosition = CurrentToken.Position
	var Data:Array = []
	SetNextToken()
	while CurrentToken.Type != Token.TYPE.RIGHT_CURLY_BRACKET:
		if Helper.call():
			break
		var Result = GetExpression.call()
		if Result is Error:
			return Result
		Data.append(Result)
		if Helper.call():
			break
	if CurrentToken.Type == Token.TYPE.RIGHT_CURLY_BRACKET:
		Position.extend(CurrentToken.Position)
		SetNextToken()
		return DataVertex.new(DataToken.DATATYPE.INSTRUCTIONS, Position, {'instructions':Data})
	else:
		return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position)

func GetOperandVertex():
	if CurrentToken is DataToken:
		var Operand:DataVertex = DataVertex.FromToken(CurrentToken)
		SetNextToken()
		if CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
			return GetFunctionVertex(Operand)
		return Operand
	elif CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
		SetNextToken()
		var Result = GetExpression.call()
		if Result is Error:
			return Result
		if CurrentToken.Type == Token.TYPE.RIGHT_CIRCLE_BRACKET:
			SetNextToken()
			return Result
		else:
			return Error.new(Error.TYPE.EXPECTED_TOKEN, CurrentToken.Position, '")"')
	elif CurrentToken.Type in [Token.TYPE.LEFT_CURLY_BRACKET, Token.TYPE.LEFT_SQUARE_BRACKET]:
		return GetDataBracketVertex()
	else:
		return Error.new(Error.TYPE.EXPECTED_OPERAND, CurrentToken.Position, 'Expected Operand')

func GetIfVertex(is_if:bool = true, is_else:bool = false):
	#breakpoint
	var DecisionKeyword:KeywordToken = CurrentToken
	SetNextToken()
	var Logic = null
	var Unary
	if not is_else:
		Logic = GetExpression.call()
		if Logic is Error:
			return Logic
		Unary = UnaryOperatorVertex.new(DecisionKeyword, Logic)
	if CurrentToken.Type == Token.TYPE.LEFT_CURLY_BRACKET:
		var Instructions = GetInstructionsVertex()
		if Instructions is Error:
			return Instructions
		if is_if:
			Instructions.VertexValue['else_ifs'] = []
			Instructions.VertexValue['else'] = null
		if is_else:
			return Instructions
		var If:BinaryOperatorVertex = BinaryOperatorVertex.new(Unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), Instructions)
		if not is_if:
			return If
		#breakpoint
		while CurrentToken.Type == Token.TYPE.KEYWORD and CurrentToken.TokenValue in ['elseif', 'else'] or CurrentToken.Type == Token.TYPE.END_OF_LINE:
			while CurrentToken.Type == Token.TYPE.END_OF_LINE: SetNextToken()
			if not (CurrentToken.TokenValue is String):
				break
			if CurrentToken.TokenValue == 'elseif':
				var else_if = GetIfVertex(false)
				if else_if is Error:
					return else_if
				Instructions.VertexValue['else_ifs'].append(else_if)
			elif CurrentToken.TokenValue == 'else':
				var else_ = GetIfVertex(false, true)
				if else_ is Error:
					return else_
				Instructions.VertexValue['else'] = else_
				break
			else:
				break
		return If
	else:
		return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)

func GetMatchVertex(default:bool = false):
	var Keyword:KeywordToken = CurrentToken
	SetNextToken()
	var Result = null
	var Unary
	if default:
		Unary = KeywordVertex.FromToken(Keyword)
	else:
		Result = GetExpression.call()
		if Result is Error:
			return Result
		Unary = UnaryOperatorVertex.new(Keyword, Result)
	if CurrentToken.Type == Token.TYPE.LEFT_CURLY_BRACKET:
		var Instructions = GetInstructionsVertex()
		if Instructions is Error:
			return Instructions
		return BinaryOperatorVertex.new(Unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), Instructions)
	else:
		return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)

func GetUnaryVertex():
	match CurrentToken.Type:
		Token.TYPE.DATA, Token.TYPE.LEFT_CURLY_BRACKET, Token.TYPE.LEFT_SQUARE_BRACKET, Token.TYPE.LEFT_CIRCLE_BRACKET:
			return GetOperandVertex()
		Token.TYPE.KEYWORD:
			match CurrentToken.TokenValue:
				'Const', 'Static', 'Public', 'Private', 'Void':
					var Modifier:KeywordToken = CurrentToken
					SetNextToken()
					var UnaryOperator = GetUnaryVertex()
					if UnaryOperator is Error:
						return UnaryOperator
					return KeywordVertex.new(Modifier.Keyword, Modifier.Position, {'Modifier':Modifier.TokenValue,'UnaryOperator':UnaryOperator})
				DataToken.DATATYPE.VARIANT, DataToken.DATATYPE.BOOLEAN, DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.OBJECT:
					var DataTypeKeyword:KeywordToken = CurrentToken
					SetNextToken()
					var Identifier = GetOperandVertex()
					if Identifier is Error:
						if Identifier.Type == Error.TYPE.EXPECTED_OPERAND:
							return KeywordVertex.new(DataTypeKeyword.Keyword, DataTypeKeyword.Position, DataTypeKeyword.TokenValue)
						else:
							return Identifier
					return UnaryOperatorVertex.new(DataTypeKeyword, Identifier)
				DataToken.DATATYPE.ENUMERATION:
					var DataTypeKeyword:KeywordToken = CurrentToken
					SetNextToken()
					var Identifier = GetOperandVertex()
					if Identifier is Error:
						if Identifier.Type == Error.TYPE.EXPECTED_OPERAND:
							return KeywordVertex.new(DataTypeKeyword.Keyword, DataTypeKeyword.Position, DataTypeKeyword.TokenValue)
						else:
							return Identifier
					var Data = GetDataBracketVertex()
					if Data is Error:
						return Data
					return BinaryOperatorVertex.new(UnaryOperatorVertex.new(DataTypeKeyword, Identifier), OperatorToken.new(OperatorToken.OPERATORTYPE.ASSIGN), Data)
				'Break', 'Continue', 'Breakpoint':
					var Keyword:KeywordToken = CurrentToken
					SetNextToken()
					return KeywordVertex.FromToken(Keyword)
				'Return':
					var Keyword:KeywordToken = CurrentToken
					SetNextToken()
					var Operand = GetExpression.call()
					if Operand is Error:
						return Operand
					return UnaryOperatorVertex.new(Keyword, Operand)
				'if':
					return GetIfVertex()
				'Match', 'Case':
					return GetMatchVertex()
				'Default':
					return GetMatchVertex(true)
				'For', 'While':
					var Keyword:KeywordToken = CurrentToken
					SetNextToken()
					var Result = GetExpression.call()
					if Result is Error:
						return Result
					var Unary:UnaryOperatorVertex = UnaryOperatorVertex.new(Keyword, Result)
					if CurrentToken.Type == Token.TYPE.LEFT_CURLY_BRACKET:
						var Instructions = GetInstructionsVertex()
						if Instructions is Error:
							return Instructions
						return BinaryOperatorVertex.new(Unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), Instructions)
					else:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
				'Class', 'Function':
					var Keyword:KeywordToken = CurrentToken
					SetNextToken()
					var Result = GetExpression.call()
					if Result is Error:
						return Result
					var Unary:UnaryOperatorVertex = UnaryOperatorVertex.new(Keyword, Result)
					if CurrentToken.Type == Token.TYPE.LEFT_CURLY_BRACKET:
						var Instructions = GetInstructionsVertex()
						if Instructions is Error:
							return Instructions
						return BinaryOperatorVertex.new(Unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), Instructions)
					else:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
				'Print', 'Range', 'Assert':
					var Keyword:KeywordToken = CurrentToken
					SetNextToken()
					return GetFunctionVertex(Keyword)
				_:
					return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
		Token.TYPE.OPERATOR:
			if CurrentToken.OperatorType in [OperatorToken.OPERATORTYPE.NOT, OperatorToken.OPERATORTYPE.ADD, OperatorToken.OPERATORTYPE.SUBTRACT]:
				var Operator = CurrentToken
				SetNextToken()
				var Result = GetOperandVertex()
				if Result is Error:
					return Result
				return UnaryOperatorVertex.new(Operator, Result)
			else:
				return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position, 'Unexpected Unary Operand')
		_:
			return Error.new(Error.TYPE.EXPECTED_OPERAND, CurrentToken.Position, 'Expected Operand')

func GetFunctionVertex(Result):
	var Type:DataToken.DATATYPE
	match CurrentToken.Type:
		Token.TYPE.LEFT_SQUARE_BRACKET: Type = DataToken.DATATYPE.SELECTOR
		Token.TYPE.LEFT_CIRCLE_BRACKET: Type = DataToken.DATATYPE.FUNCTION
	var Parameters = GetDataBracketVertex()
	if Parameters is Error:
		return Parameters
	var Position:TokenPosition
	if Result.Position:
		Position = Result.Position.duplicate()
	else:
		Position = Parameters.Position
	return DataVertex.FromToken(DataToken.new(Type, Position.extend(Parameters.Position), {'Identifier':Result, 'Parameters':Parameters}))

func GetBinaryVertex(function:Callable = func (): pass, operators:Array = []):
	#breakpoint
	var Result = function.call()
	if Result is Error:
		return Result
	while CurrentToken.Type == Token.TYPE.LEFT_SQUARE_BRACKET:
		if Result is DataVertex and Result.DataType in [DataToken.DATATYPE.IDENTIFIER, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.FUNCTION]:
			Result = GetFunctionVertex(Result)
		else:
			Result = GetFunctionVertex(Result)
	if Result is Error:
		return Result
	while CurrentToken is OperatorToken and (CurrentToken.OperatorType in operators):
		var Operator:OperatorToken = CurrentToken
		SetNextToken()
		var Right = function.call()
		if Right is Error:
			return Right
		Result = BinaryOperatorVertex.new(Result, Operator, Right)
	return Result

func Parse(tokens:Array[Token]):
	Tokens = tokens.duplicate()
	Index = -1
	CurrentToken = null
	Parsed.clear()
	SetNextToken()
	while CurrentToken:
		match CurrentToken.Type:
			Token.TYPE.END_OF_LINE, Token.TYPE.END_OF_FILE:
				SetNextToken()
			_:
				var Result = GetExpression.call()
				if Result is Error:
					return Result
				Parsed.append(Result)
	return Parsed
