class_name Parser
const PRECEDENCE:Array[Array] = [
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
var get_statement:Callable = func (inner_function_1:Callable = get_unary_vertex) : return get_binary_vertex(
								func (inner_function_2:Callable = inner_function_1) : return get_binary_vertex(
									func (inner_function_3:Callable = inner_function_2) : return get_binary_vertex(
										func (inner_function_4:Callable = inner_function_3) : return get_binary_vertex(
											func (inner_function_5:Callable = inner_function_4) : return get_binary_vertex(
												func (inner_function_6:Callable = inner_function_5) : return get_binary_vertex(
													func (inner_function_7:Callable = inner_function_6) : return get_binary_vertex(
														func (inner_function_8:Callable = inner_function_7) : return get_binary_vertex(
															func (inner_function_9:Callable = inner_function_8) : return get_binary_vertex(
																func (inner_function_10:Callable = inner_function_9) : return get_binary_vertex(
																	func (inner_function_11:Callable = inner_function_10) : return get_binary_vertex(
																		func (inner_function_12:Callable = inner_function_11) : return get_binary_vertex(
																			inner_function_12,
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
var Index:int
var CurrentToken:Token
var Tokens:Array
var Parsed:Array

func next_token() -> void:
	Index += 1
	assert(Index - Tokens.size() < 1)
	CurrentToken = Tokens[Index] if Index < Tokens.size() else null

func get_bracket_data_vertex():
	var helper:Callable = func (en:Token.TYPE) -> bool:
		while CurrentToken.Type == Token.TYPE.END_OF_LINE: next_token()
		if CurrentToken.Type == en + 1: return true
		return false
	var encloser:Token.TYPE = CurrentToken.Type
	var position:TokenPosition = CurrentToken.Position
	var data:Array = []
	next_token()
	while CurrentToken.Type != Token.TYPE.COMMA:
		if helper.call(encloser):
			break
		var expression = get_statement.call()
		if expression is Error:
			return expression
		data.append(expression)
		if helper.call(encloser):
			break
		if CurrentToken.Type == Token.TYPE.COMMA:
			next_token()
		else:
			return Error.new(Error.TYPE.EXPECTED_TOKEN, CurrentToken.Position, '","')
	if CurrentToken.Type == encloser + 1:
		position.extend(CurrentToken.Position)
		next_token()
		match encloser:
			Token.TYPE.LEFT_CURLY_BRACKET:
				return DataVertex.FromToken(DataToken.new(DataToken.DATATYPE.DICTIONARY, position, data))
			Token.TYPE.LEFT_SQUARE_BRACKET:
				return DataVertex.FromToken(DataToken.new(DataToken.DATATYPE.LIST, position, data))
			Token.TYPE.LEFT_CIRCLE_BRACKET:
				return DataVertex.FromToken(DataToken.new(DataToken.DATATYPE.PARAMETER, position, data))
			
	else:
		return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position)

func get_instructions_vertex():
	var helper:Callable = func () -> bool:
		while CurrentToken.Type == Token.TYPE.END_OF_LINE: next_token()
		if CurrentToken.Type == Token.TYPE.RIGHT_CURLY_BRACKET: return true
		return false
	var position:TokenPosition = CurrentToken.Position
	var instructions:Array = []
	next_token()
	while CurrentToken.Type != Token.TYPE.RIGHT_CURLY_BRACKET:
		if helper.call():
			break
		var Result = get_statement.call()
		if Result is Error:
			return Result
		instructions.append(Result)
		if helper.call():
			break
	if CurrentToken.Type == Token.TYPE.RIGHT_CURLY_BRACKET:
		position.extend(CurrentToken.Position)
		next_token()
		return DataVertex.new(DataToken.DATATYPE.INSTRUCTIONS, position, {'instructions':instructions})
	else:
		return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position)

func get_operand_vertex(inner_function:Callable = get_unary_vertex):
	if CurrentToken is DataToken:
		var operand:DataVertex = DataVertex.FromToken(CurrentToken)
		next_token()
		if CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
			return get_function_vertex(operand)
		return operand
	elif CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
		next_token()
		var expression = get_statement.call(inner_function)
		if CurrentToken.Type != Token.TYPE.RIGHT_CIRCLE_BRACKET:
			return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
		if expression is Error:
			return expression
		next_token()
		return expression
	elif CurrentToken.Type in [Token.TYPE.LEFT_CURLY_BRACKET, Token.TYPE.LEFT_SQUARE_BRACKET]:
		return get_bracket_data_vertex()
	else:
		return Error.new(Error.TYPE.EXPECTED_OPERAND, CurrentToken.Position, 'Expected Operand')

func get_if_vertex(statement:int = 0):
	const IF = 0
	const ESLE_IF = 1
	const ELSE = 2
	var decision_keyword:KeywordToken = CurrentToken
	var unary:UnaryOperatorVertex
	next_token()
	if statement != ELSE:
		if  !(CurrentToken.Type in [Token.TYPE.LEFT_CIRCLE_BRACKET, Token.TYPE.DATA]):
			return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position)
		var expression = get_statement.call(get_operand_vertex.bind(get_operand_vertex))
		if expression is Error:
			return expression
		unary = UnaryOperatorVertex.new(decision_keyword, expression)
	if CurrentToken.Type != Token.TYPE.LEFT_CURLY_BRACKET:
		return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
	var instructions = get_instructions_vertex()
	if instructions is Error:
		return instructions
	match statement:
		IF:
			instructions.Data['else_ifs'] = []
			instructions.Data['else'] = null
		ELSE:
			return instructions
	var if_statement:BinaryOperatorVertex = BinaryOperatorVertex.new(unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), instructions)
	if statement != IF:
		return if_statement
	while CurrentToken.Type == Token.TYPE.KEYWORD and CurrentToken.TokenValue in ['elseif', 'else'] or CurrentToken.Type == Token.TYPE.END_OF_LINE:
		while CurrentToken.Type == Token.TYPE.END_OF_LINE: next_token()
		if not (CurrentToken.TokenValue is String):
			break
		if CurrentToken.TokenValue == 'elseif':
			var else_if_statement = get_if_vertex(ESLE_IF)
			if else_if_statement is Error:
				return else_if_statement
			instructions.Data['else_ifs'].append(else_if_statement)
		elif CurrentToken.TokenValue == 'else':
			var else_statement = get_if_vertex(ELSE)
			if else_statement is Error:
				return else_statement
			instructions.Data['else'] = else_statement
			break
		else:
			break
	return if_statement

#func get_match_vertex(default:bool = false):
	#var Keyword:KeywordToken = CurrentToken
	#next_token()
	#var Result = null
	#var Unary
	#if default:
		#Unary = KeywordVertex.FromToken(Keyword)
	#else:
		#Result = get_expression.call()
		#if Result is Error:
			#return Result
		#Unary = UnaryOperatorVertex.new(Keyword, Result)
	#if CurrentToken.Type == Token.TYPE.LEFT_CURLY_BRACKET:
		#var Instructions = get_instructions_vertex()
		#if Instructions is Error:
			#return Instructions
		#return BinaryOperatorVertex.new(Unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), Instructions)
	#else:
		#return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)

func get_unary_vertex():
	match CurrentToken.Type:
		Token.TYPE.DATA, Token.TYPE.LEFT_CURLY_BRACKET, Token.TYPE.LEFT_SQUARE_BRACKET, Token.TYPE.LEFT_CIRCLE_BRACKET:
			return get_operand_vertex()
		Token.TYPE.KEYWORD:
			match CurrentToken.TokenValue:
				'Const', 'Static', 'Public', 'Private', 'Void':
					return Error.new(Error.TYPE.MESSAGE, CurrentToken.Position, 'UnImplemented Keyword')
					#var Modifier:KeywordToken = CurrentToken
					#next_token()
					#var UnaryOperator = get_unary_vertex()
					#if UnaryOperator is Error:
						#return UnaryOperator
					#return KeywordVertex.new(Modifier.Keyword, Modifier.Position, {'Modifier':Modifier.TokenValue,'UnaryOperator':UnaryOperator})
				DataToken.DATATYPE.OBJECT:
					return Error.new(Error.TYPE.MESSAGE, CurrentToken.Position, 'UnImplemented Keyword')
				DataToken.DATATYPE.VARIANT, DataToken.DATATYPE.BOOLEAN, DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.OBJECT:
					var keyword:KeywordToken = CurrentToken
					next_token()
					if CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
						return get_function_vertex(keyword)
					elif CurrentToken is DataToken:
						var operand = get_operand_vertex()
						if operand is Error:
							return operand
						return UnaryOperatorVertex.new(keyword, operand)
					elif CurrentToken.Type in [Token.TYPE.LEFT_CURLY_BRACKET, Token.TYPE.LEFT_SQUARE_BRACKET]:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
					return KeywordVertex.FromToken(keyword)
				DataToken.DATATYPE.ENUMERATION:
					var keyword:KeywordToken = CurrentToken
					next_token()
					if CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
						return get_function_vertex(keyword)
					elif CurrentToken is DataToken:
						var operand = get_operand_vertex()
						if CurrentToken.Type != Token.TYPE.LEFT_CURLY_BRACKET:
							return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
						if operand is Error:
							return operand
						var bracket_data = get_bracket_data_vertex()
						if bracket_data is Error:
							return bracket_data
						return BinaryOperatorVertex.new(UnaryOperatorVertex.new(keyword, operand), OperatorToken.new(OperatorToken.OPERATORTYPE.ASSIGN), bracket_data)
					return KeywordVertex.FromToken(keyword)
				'Return', 'Break', 'Continue', 'Breakpoint':
					var keyword:KeywordToken = CurrentToken
					next_token()
					if CurrentToken.Type in [Token.TYPE.LEFT_CIRCLE_BRACKET, Token.TYPE.LEFT_CURLY_BRACKET, Token.TYPE.LEFT_SQUARE_BRACKET, Token.TYPE.DATA]:
						if keyword.TokenValue != 'Return':
							return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position)
						var expression = get_statement.call(get_operand_vertex.bind(get_operand_vertex))
						if expression is Error:
							return expression
						return UnaryOperatorVertex.new(keyword, expression)
					else:
						if keyword.TokenValue == 'Return':
							return Error.new(Error.TYPE.EXPECTED_OPERAND, keyword.Position)
					return KeywordVertex.FromToken(keyword)
				'if':
					return get_if_vertex()
				'Match', 'Case':
					return Error.new(Error.TYPE.MESSAGE, CurrentToken.Position, 'UnImplemented Keyword')
					#return get_match_vertex()
				'Default':
					return Error.new(Error.TYPE.MESSAGE, CurrentToken.Position, 'UnImplemented Keyword')
					#return get_match_vertex(true)
				'For', 'While':
					var keyword:KeywordToken = CurrentToken
					next_token()
					var expression = get_binary_vertex(get_unary_vertex, PRECEDENCE[6]) if keyword.TokenValue == 'For' else get_statement.call(get_operand_vertex.bind(get_operand_vertex))
					if CurrentToken.Type != Token.TYPE.LEFT_CURLY_BRACKET:
						return Error.new(Error.TYPE.EXPECTED_TOKEN, CurrentToken.Position, "'{'")
					if expression is Error:
						return expression
					var unary:UnaryOperatorVertex = UnaryOperatorVertex.new(keyword, expression)
					var instructions = get_instructions_vertex()
					if instructions is Error:
						return instructions
					return BinaryOperatorVertex.new(unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), instructions)
				'Class':
					return Error.new(Error.TYPE.MESSAGE, CurrentToken.Position, 'UnImplemented Keyword')
				'Function':
					var keyword:KeywordToken = CurrentToken
					next_token()
					if CurrentToken.Type != Token.TYPE.KEYWORD:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
					if not (CurrentToken.Keyword in [KeywordToken.KEYWORD.DATATYPE, KeywordToken.KEYWORD.MODIFIER]):
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
					var expression = get_statement.call()
					if CurrentToken.Type != Token.TYPE.LEFT_CURLY_BRACKET:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
					if expression is Error:
						return expression
					var unary:UnaryOperatorVertex = UnaryOperatorVertex.new(keyword, expression)
					var instructions = get_instructions_vertex()
					if instructions is Error:
						return instructions
					return BinaryOperatorVertex.new(unary, OperatorToken.new(OperatorToken.OPERATORTYPE.RUNS), instructions)
				'Print', 'Range', 'Assert', 'Random', 'Input':
					var keyword:KeywordToken = CurrentToken
					next_token()
					if CurrentToken.Type == Token.TYPE.LEFT_CIRCLE_BRACKET:
						return get_function_vertex(keyword)
					else:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
				_:
					return Error.new(Error.TYPE.UNEXPECTED_TOKEN, CurrentToken.Position)
		Token.TYPE.OPERATOR:
			if CurrentToken.OperatorType in [OperatorToken.OPERATORTYPE.NOT, OperatorToken.OPERATORTYPE.ADD, OperatorToken.OPERATORTYPE.SUBTRACT]:
				var operator:OperatorToken = CurrentToken
				next_token()
				var operand = get_operand_vertex()
				if operand is Error:
					return operand
				return UnaryOperatorVertex.new(operator, operand)
			else:
				return Error.new(Error.TYPE.UNEXPECTED_OPERAND, CurrentToken.Position, 'Unexpected Unary Operand')
		_:
			return Error.new(Error.TYPE.EXPECTED_OPERAND, CurrentToken.Position)

func get_function_vertex(identifier):
	var type:DataToken.DATATYPE
	match CurrentToken.Type:
		Token.TYPE.LEFT_SQUARE_BRACKET: type = DataToken.DATATYPE.SELECTOR
		Token.TYPE.LEFT_CIRCLE_BRACKET: type = DataToken.DATATYPE.FUNCTION
	var parameters = get_bracket_data_vertex()
	if parameters is Error:
		return parameters
	var position:TokenPosition = identifier.Position.duplicate() if identifier.Position else parameters.Position
	return DataVertex.FromToken(DataToken.new(type, position.extend(parameters.Position), {'Identifier':identifier, 'Parameters':parameters}))

func get_binary_vertex(function:Callable = func (): pass, operators:Array = []):
	var left = function.call()
	if left is Error:
		return left
	while CurrentToken.Type == Token.TYPE.LEFT_SQUARE_BRACKET:
		left = get_function_vertex(left)
		if left is Error:
			return left
	while CurrentToken is OperatorToken and (CurrentToken.OperatorType in operators):
		var operator:OperatorToken = CurrentToken
		next_token()
		var right = function.call()
		if right is Error:
			return right
		left = BinaryOperatorVertex.new(left, operator, right)
	return left

func Parse(tokens:Array[Token]):
	Tokens = tokens.duplicate()
	Index = -1
	CurrentToken = null
	Parsed.clear()
	next_token()
	while CurrentToken:
		match CurrentToken.Type:
			Token.TYPE.END_OF_LINE, Token.TYPE.END_OF_FILE:
				next_token()
			_:
				var statement = get_statement.call()
				if statement is Error:
					return statement
				Parsed.append(statement)
	return Parsed
