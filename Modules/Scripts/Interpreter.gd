class_name Interpreter
static var Output:String = ''

class Storage:
	var Parent:Storage = null
	var Variables:Dictionary
	var Functions:Dictionary
	var function_child:bool = false
	
	func _init(variables:Dictionary = {}, functions:Dictionary = {}) -> void:
		Variables = variables
		Functions = functions
	
	func create_child() -> Storage:
		var child:Storage = get_script().new()
		child.Parent = self
		return child
	
	func create_function_child(return_type) -> Storage:
		var child:Storage = get_script().new()
		child.Functions = Functions
		child.function_child = true
		child.create_variable('Return', MarbleData.new(return_type))
		return child
	
	func reset() -> void:
		Variables.clear()
		Functions.clear()
	
	func create_variable(name:String, value:MarbleData = null) -> MarbleData:
		Variables[name] = value
		return value
	
	func delete_variable(name:String) -> void:
		Variables.erase(name)
	
	func has_variable(name:String) -> bool:
		var has:bool = Variables.has(name)
		if not has:
			if Parent:
				has = Parent.has_variable(name)
		return has
	
	func set_variable(name:String, value:MarbleData) -> void:
		if Variables.has(name):
			Variables[name] = value
		else:
			if Parent:
				Parent.set_variable(name, value)
	
	func get_variable(name:String):
		if Variables.has(name):
			return Variables[name]
		else:
			if Parent:
				return Parent.get_variable(name)
	
	func create_function(name:String, value:MarbleFunction = null) -> void:
		Functions[name] = value
	
	func delete_function(name:String) -> void:
		Functions.erase(name)
	
	func has_function(name:String) -> bool:
		var has:bool = Functions.has(name)
		if not has:
			if Parent:
				has = Parent.has_function(name)
		return has
	
	func set_function(name:String, key:String, value) -> void:
		if Functions.has(name):
			Functions[name][key] = value
		else:
			if Parent:
				Parent.set_function(name, key, value)
	
	func get_function(name:String):
		if Functions.has(name):
			return Functions[name]
		else:
			if Parent:
				return Parent.get_function(name)
	
	func _to_string() -> String:
		var result:String = 'Variables:\n'
		for variable:String in Variables:
			result += "%s %s = %s\n" % [DataToken.DATATYPE.keys()[Variables[variable].Type], variable, Variables[variable]]
		return result

class DataOperator:
	static func get_raw_datatype(value) -> DataToken.DATATYPE:
		if value is bool:
			return DataToken.DATATYPE.BOOLEAN
		elif value is int:
			return DataToken.DATATYPE.INTEGER
		elif value is float:
			return DataToken.DATATYPE.FLOAT
		elif value is String:
			return DataToken.DATATYPE.STRING
		elif value is Array:
			return DataToken.DATATYPE.LIST
		elif value is Dictionary:
			return DataToken.DATATYPE.DICTIONARY
		elif value is MarbleEnumeration:
			return DataToken.DATATYPE.ENUMERATION
		elif value is MarbleObject or value == null:
			return DataToken.DATATYPE.OBJECT
		else:
			breakpoint
			return DataToken.DATATYPE.NONE
			
	static func try_convert(operand:MarbleData, type:DataToken.DATATYPE) -> MarbleData:
		var data:MarbleData = MarbleData.new(type)
		match operand.Type:
			DataToken.DATATYPE.VARIANT:
				return try_convert(MarbleData.new(get_raw_datatype(operand.Value), operand.Value), type)
			DataToken.DATATYPE.BOOLEAN:
				match type:
					DataToken.DATATYPE.INTEGER:
						data.Value = int(operand.Value)
					DataToken.DATATYPE.FLOAT:
						data.Value = float(operand.Value)
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.INTEGER:
				match type:
					DataToken.DATATYPE.FLOAT:
						data.Value = float(operand.Value)
					DataToken.DATATYPE.BOOLEAN:
						data.Value = bool(operand.Value)
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.FLOAT:
				match type:
					DataToken.DATATYPE.INTEGER:
						data.Value = int(operand.Value)
					DataToken.DATATYPE.BOOLEAN:
						data.Value = bool(operand.Value)
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.STRING:
				match type:
					DataToken.DATATYPE.BOOLEAN:
						data.Value = bool(operand.Value)
					DataToken.DATATYPE.INTEGER:
						data.Value = int(operand.Value)
					DataToken.DATATYPE.FLOAT:
						data.Value = float(operand.Value)
					DataToken.DATATYPE.LIST:
						data.Value = []
						for x in operand.Value:
							data.Value.append(x)
					_:
						return null
			DataToken.DATATYPE.LIST:
				match type:
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
			DataToken.DATATYPE.DICTIONARY:
				match type:
					DataToken.DATATYPE.STRING:
						data.Value = str(operand.Value)
					_:
						return null
		return data
	
	static func add(left:MarbleData, right:MarbleData) -> MarbleData:
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) + int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) + right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) + right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value + int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value + right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) + right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value + float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value + float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value + right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.STRING, left.Value + str(right.Value))
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.LIST, left.Value + [right.Value])
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.STRING, str(left.Value) + right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.LIST, [left.Value] + right.Value)
					DataToken.DATATYPE.DICTIONARY:
						var M:Dictionary = left.Value
						M.merge(right.Value, true)
						data = MarbleData.new(DataToken.DATATYPE.DICTIONARY, M)
		return data

	static func subtract(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) - int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) - right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) - right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value - int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value - right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) - right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value - float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value - float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value - right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data

	static func multiply(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) * int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) * right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) * right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value * int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value * right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) * right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value * float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value * float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value * right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data

	static func divide(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) / right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) / right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) / float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) / right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value / float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value / right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data
	
	static func exponent(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, pow(int(left.Value), int(right.Value)))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, pow(int(left.Value), right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(float(left.Value), right.Value))
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, pow(left.Value, int(right.Value)))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(float(left.Value), right.Value))
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, int(right.Value)))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, float(right.Value)))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, pow(left.Value, right.Value))
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data
		
	static func modolus(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) % int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, int(left.Value) % right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) % right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value % int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.INTEGER, left.Value % right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, float(left.Value) % right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value % float(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value % float(right.Value))
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.FLOAT, left.Value % right.Value)
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.LIST:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
		return data
	
	static func And(left:MarbleData, right:MarbleData):
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value and right.Value)
	
	static func Or(left:MarbleData, right:MarbleData):
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value or right.Value)
	
	static func equals(left:MarbleData, right:MarbleData):
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value == right.Value)
	
	static func not_equals(left:MarbleData, right:MarbleData) -> MarbleData:
		return MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value != right.Value)
		
	static func greater_than(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) > right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() > right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value > int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() > right.Value.size())
		return data
		
	static func greater_than_or_equals(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) >= right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() >= right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value >= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() >= right.Value.size())
		return data
		
	static func lesser_than(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) < right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() < right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value < int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() < right.Value.size())
		return data
		
	static func lesser_than_or_equals(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, int(left.Value) <= right.Value.size())
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= right.Value.size())
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.length() <= right.Value.size())
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value <= int(right.Value))
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value.length())
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value.size())
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value.size() <= right.Value.size())
		return data
	
	static func is_in(left:MarbleData, right:MarbleData):
		var data:MarbleData = null
		var L_Type:DataToken.DATATYPE = left.Type
		var R_Type:DataToken.DATATYPE = right.Type
		if L_Type == DataToken.DATATYPE.VARIANT:
			L_Type = get_raw_datatype(left.Value)
		if R_Type == DataToken.DATATYPE.VARIANT:
			R_Type = get_raw_datatype(right.Value)
		match L_Type:
			DataToken.DATATYPE.BOOLEAN:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						pass
					DataToken.DATATYPE.LIST:
						pass
					DataToken.DATATYPE.DICTIONARY:
						pass
			DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						pass
					DataToken.DATATYPE.FLOAT:
						pass
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
			DataToken.DATATYPE.STRING:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
			DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY:
				match R_Type:
					DataToken.DATATYPE.BOOLEAN:
						pass
					DataToken.DATATYPE.INTEGER:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.FLOAT:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.STRING:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.LIST:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
					DataToken.DATATYPE.DICTIONARY:
						data = MarbleData.new(DataToken.DATATYPE.BOOLEAN, left.Value in right.Value)
		return data
	
	static func negate(operand:MarbleData) -> MarbleData:
		var data:MarbleData = MarbleData.new(operand.Type)
		if operand.Type == DataToken.DATATYPE.BOOLEAN:
			data.Value = !operand.Value
		elif operand.Type in [DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT]:
			data.Value = -operand.Value
		elif operand.Type == DataToken.DATATYPE.LIST:
			data.Value = operand.Value
			data.Value.reverse()
		else:
			return null
		return data

func InterpreteVertex(vertex:Vertex, StorageObject:Storage):
	if vertex is BinaryOperatorVertex:
		return InterpreteBinaryVertex(vertex, StorageObject)
	elif vertex is UnaryOperatorVertex:
		return InterpreteUnaryVertex(vertex, StorageObject)
	elif vertex is KeywordVertex:
		return InterpreteKeywordVertex(vertex, StorageObject)
	elif vertex is DataVertex:
		return InterpreteDataVertex(vertex, StorageObject)

func InterpreteDataVertex(vertex:DataVertex, StorageObject:Storage):
	match vertex.DataType:
		DataToken.DATATYPE.FUNCTION:
			if vertex.VertexValue.Identifier is KeywordToken:
				match vertex.VertexValue.Identifier.TokenValue:
					'Print':
						for parameter in vertex.VertexValue.Parameters.VertexValue:
							var result = InterpreteVertex(parameter, StorageObject)
							if result is Error:
								return result
							Output += str(result.Value) + ' '
						Output += '\n'
					'Range':
						var result = InterpreteVertex(vertex.VertexValue.Parameters.VertexValue[0], StorageObject)
						if result is Error:
							return result
						var list:Array = []
						for x in result.Value:
							list.append(MarbleData.new(DataToken.DATATYPE.INTEGER, x))
						return MarbleData.new(DataToken.DATATYPE.LIST, list)
					'Assert':
						var result = InterpreteVertex(vertex.VertexValue.Parameters.VertexValue[0], StorageObject)
						if result is Error:
							return result
						if !result.Value:
							return Error.new(Error.TYPE.ASSERTION_FAILED, vertex.VertexValue.Parameters.Position)
					_:
						breakpoint
						
						
			else:
				if StorageObject.has_function(vertex.VertexValue.Identifier.VertexValue):
					var Function:MarbleFunction = StorageObject.get_function(vertex.VertexValue.Identifier.VertexValue)
					var child_storage_object:Storage = StorageObject.create_function_child(Function.Type)
					var Parameter:Array = vertex.VertexValue.Parameters.VertexValue
					for index in Function.Parameters.size():
						var Argument = InterpreteVertex(Function.Parameters[index], child_storage_object)
						if Argument is Error:
							return Argument
						if index < Parameter.size():
							var ret = InterpreteVertex(Parameter[index], StorageObject)
							if ret is Error:
								return ret
							Argument.Value = ret.Value
						elif Argument.Value == null:
							breakpoint
					var res = Interprete(Function.Instructions, child_storage_object)
					return res
				else:
					return Error.new(Error.TYPE.MESSAGE, vertex.Position, 'Undefined Function')
		DataToken.DATATYPE.SELECTOR:
			if vertex.VertexValue.Parameters.VertexValue.size() != 1:
				return Error.new(Error.TYPE.MESSAGE, vertex.Position, 'What does this mean!?')
			var Identifier = InterpreteVertex(vertex.VertexValue.Identifier, StorageObject)
			if Identifier is Error:
				return Identifier
			if Identifier.Type == DataToken.DATATYPE.VARIANT:
				Identifier.Type = DataOperator.get_raw_datatype(Identifier.Value)
			match Identifier.Type:
				DataToken.DATATYPE.LIST:
					var result = InterpreteVertex(vertex.VertexValue.Parameters.VertexValue[0], StorageObject)
					if result is Error:
						return result
					if result.Type != DataToken.DATATYPE.INTEGER:
						return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.VertexValue.Parameters.VertexValue[0].Position)
					if result.Value >= Identifier.Value.size():
						return Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position)
					var Value = Identifier.Value[result.Value]
					return MarbleData.new(DataOperator.get_raw_datatype(Value), Value)
				DataToken.DATATYPE.DICTIONARY:
					var result = InterpreteVertex(vertex.VertexValue.Parameters.VertexValue[0], StorageObject)
					if result is Error:
						return result
					if !Identifier.Value.has(result.Value):
						return Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position)
					var Value = Identifier.Value[result.Value]
					return MarbleData.new(DataOperator.get_raw_datatype(Value), Value)
				DataToken.DATATYPE.STRING:
					var result = InterpreteVertex(vertex.VertexValue.Parameters.VertexValue[0], StorageObject)
					if result is Error:
						return result
					if result.Type != DataToken.DATATYPE.INTEGER:
						return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.VertexValue.Parameters.VertexValue[0].Position)
					if result.Value >= Identifier.Value.length():
						return Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position)
					return MarbleData.new(DataToken.DATATYPE.STRING, Identifier.Value[result.Value])
				_:
					breakpoint
		DataToken.DATATYPE.IDENTIFIER:
			if StorageObject.has_variable(vertex.VertexValue):
				var MarbleDataObject:MarbleData = StorageObject.get_variable(vertex.VertexValue)
				if MarbleDataObject.Type != DataToken.DATATYPE.VARIANT and MarbleDataObject.Value == null:
					return Error.new(Error.TYPE.UNINITIALIZED_IDENTIFIER, vertex.Position)
				return MarbleDataObject
			else:
				return Error.new(Error.TYPE.UNDEFINED_IDENTIFIER, vertex.Position)
		DataToken.DATATYPE.INSTRUCTIONS:
			if vertex.VertexValue.size() == 1:
				return InterpreteVertex(vertex.VertexValue[0], StorageObject)
			else:
				print(vertex)
				breakpoint
		DataToken.DATATYPE.LIST:
			var Data:Array = []
			for item:Vertex in vertex.VertexValue:
				var res = InterpreteVertex(item, StorageObject)
				if res is Error:
					return res
				res.Type = DataToken.DATATYPE.VARIANT
				Data.append(res)
			return MarbleData.new(DataToken.DATATYPE.LIST, Data)
		DataToken.DATATYPE.DICTIONARY:
			var Data:Dictionary = {}
			for item:Vertex in vertex.VertexValue:
				var res = InterpreteVertex(item, StorageObject)
				if res is Error:
					return res
				Data.merge(res.Value, true)
			return MarbleData.new(DataToken.DATATYPE.DICTIONARY, Data)
		_:
			return MarbleData.FromDataVertex(vertex)

func InterpreteBinaryVertex(vertex:BinaryOperatorVertex, StorageObject:Storage):
	match vertex.Operator.OperatorType:
		OperatorToken.OPERATORTYPE.DOT:
			print(vertex)
			breakpoint
		OperatorToken.OPERATORTYPE.ADD:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			var Result:MarbleData = DataOperator.add(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.SUBTRACT:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			var Result:MarbleData = DataOperator.subtract(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.MULTIPLY:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			var Result:MarbleData = DataOperator.multiply(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.DIVIDE:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Right.Type in [DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT]:
				if float(Right.Value) == 0:
					return Error.new(Error.TYPE.DIVISION_BY_ZERO, vertex.VertexValue.right.Position)
			var Result:MarbleData = DataOperator.divide(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.EXPONENT:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			var Result:MarbleData = DataOperator.exponent(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.MODOLUS:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			var Result:MarbleData = DataOperator.modolus(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.AND:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.And(Left, Right)
		OperatorToken.OPERATORTYPE.OR:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.Or(Left, Right)
		OperatorToken.OPERATORTYPE.IN:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			var Result:MarbleData = DataOperator.is_in(Left, Right)
			if !Result:
				return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, vertex.Position)
			return Result
		OperatorToken.OPERATORTYPE.EQUALS:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.equals(Left, Right)
		OperatorToken.OPERATORTYPE.NOT_EQUALS:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.not_equals(Left, Right)
		OperatorToken.OPERATORTYPE.GREATER_THAN:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.greater_than(Left, Right)
		OperatorToken.OPERATORTYPE.GREATER_THAN_OR_EQUALS:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.greater_than_or_equals(Left, Right)
		OperatorToken.OPERATORTYPE.LESSER_THAN:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.lesser_than(Left, Right)
		OperatorToken.OPERATORTYPE.LESSER_THAN_OR_EQUALS:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return DataOperator.lesser_than_or_equals(Left, Right)
		OperatorToken.OPERATORTYPE.ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			if Left.Type == DataToken.DATATYPE.ENUMERATION:
				Left.Value = MarbleEnumeration.new()
				for index:int in vertex.VertexValue.right.VertexValue.size():
					Left.Value.Value[vertex.VertexValue.right.VertexValue[index].VertexValue] = index
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Left.Type == DataToken.DATATYPE.VARIANT:
				Left.Value = Right.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = Right.Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						if Left.Type == DataToken.DATATYPE.OBJECT:
							Left.Value = MarbleObject.new(null)
						else:
							Left.Value = conv.Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.ADD_AND_ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Left.Type == DataToken.DATATYPE.VARIANT:
				var Result:MarbleData = DataOperator.add(Left, Right)
				if !Result:
					return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Right.Position)
				Left.Value = Result.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = DataOperator.add(Left, Right).Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						Left.Value = DataOperator.add(Left, conv).Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.SUBTRACT_AND_ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Left.Type == DataToken.DATATYPE.VARIANT:
				var Result:MarbleData = DataOperator.subtract(Left, Right)
				if !Result:
					return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Right.Position)
				Left.Value = Result.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = DataOperator.subtract(Left, Right).Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						Left.Value = DataOperator.subtract(Left, conv).Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.MULTIPLY_AND_ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Left.Type == DataToken.DATATYPE.VARIANT:
				var Result:MarbleData = DataOperator.multiply(Left, Right)
				if !Result:
					return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Right.Position)
				Left.Value = Result.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = DataOperator.multiply(Left, Right).Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						Left.Value = DataOperator.multiply(Left, conv).Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.DIVIDE_AND_ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Right.Type in [DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT]:
				if float(Right.Value) == 0:
					return Error.new(Error.TYPE.DIVISION_BY_ZERO, vertex.VertexValue.right.Position)
			if Left.Type == DataToken.DATATYPE.VARIANT:
				var Result:MarbleData = DataOperator.divide(Left, Right)
				if !Result:
					return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Right.Position)
				Left.Value = Result.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = DataOperator.divide(Left, Right).Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						Left.Value = DataOperator.divide(Left, conv).Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.EXPONENT_AND_ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Left.Type == DataToken.DATATYPE.VARIANT:
				var Result:MarbleData = DataOperator.exponent(Left, Right)
				if !Result:
					return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Right.Position)
				Left.Value = Result.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = DataOperator.exponent(Left, Right).Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						Left.Value = DataOperator.exponent(Left, conv).Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.MODOLUS_AND_ASSIGN:
			if vertex.VertexValue.left is DataVertex:
				if not vertex.VertexValue.left.DataType in [DataToken.DATATYPE.SELECTOR, DataToken.DATATYPE.IDENTIFIER]:
					Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.VertexValue.left.Position)
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			if Left.Type == DataToken.DATATYPE.VARIANT:
				var Result:MarbleData = DataOperator.modolus(Left, Right)
				if !Result:
					return Error.new(Error.TYPE.INCOMPATIBLE_TYPES, Right.Position)
				Left.Value = Result.Value
			else:
				if Left.Type == Right.Type:
					Left.Value = DataOperator.modolus(Left, Right).Value
				else:
					var conv = DataOperator.try_convert(Right, Left.Type)
					if conv:
						Left.Value = DataOperator.modolus(Left, conv).Value
					else:
						return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.right.Position)
			return Left
		OperatorToken.OPERATORTYPE.COLON:
			var Left = InterpreteVertex(vertex.VertexValue.left, StorageObject)
			if Left is Error:
				return Left
			if Left.Type in [DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.OBJECT]:
				return Error.new(Error.TYPE.MESSAGE, vertex.VertexValue.left.Position, 'Invalid Key')
			var Right = InterpreteVertex(vertex.VertexValue.right, StorageObject)
			if Right is Error:
				return Right
			return MarbleData.new(DataToken.DATATYPE.DICTIONARY, {Left.Value : Right.Value})
		OperatorToken.OPERATORTYPE.RUNS:
			var child_storage_object:Storage = StorageObject.create_child()
			match vertex.VertexValue.left.Operator.TokenValue:
				'Function':
					var Type:DataToken.DATATYPE = vertex.VertexValue.left.VertexValue.Operator.TokenValue
					var Name:String = vertex.VertexValue.left.VertexValue.VertexValue.VertexValue.Identifier.VertexValue
					var Parameters:Array = vertex.VertexValue.left.VertexValue.VertexValue.VertexValue.Parameters.VertexValue
					var Instructions:Array = vertex.VertexValue.right.VertexValue.instructions
					StorageObject.create_function(Name, MarbleFunction.new(Type, Name, Parameters, Instructions))
				'if':
					var if_key = InterpreteVertex(vertex.VertexValue.left.VertexValue, child_storage_object)
					if if_key is Error:
						return if_key
					if if_key.Value:
						var res = Interprete(vertex.VertexValue.right.VertexValue.instructions, child_storage_object)
						if res is Error:
							return res
					else:
						var else_ifs:Array = vertex.VertexValue.right.VertexValue.else_ifs
						var else_if_instructions = null
						for else_if:BinaryOperatorVertex in else_ifs:
							var else_if_key = InterpreteVertex(else_if.VertexValue.left.VertexValue, child_storage_object)
							if else_if_key is Error:
								return else_if_key
							if else_if_key.Value:
								else_if_instructions = else_if.VertexValue.right.VertexValue.instructions
								break
						if else_if_instructions:
							var res = Interprete(else_if_instructions, child_storage_object)
							if res is Error:
								return res
						else:
							var else_ = vertex.VertexValue.right.VertexValue.else
							if else_:
								var res = Interprete(else_.VertexValue.instructions, child_storage_object)
								if res is Error:
									return res
				'For':
					var IN:BinaryOperatorVertex = vertex.VertexValue.left.VertexValue
					if IN.Operator.OperatorType != OperatorToken.OPERATORTYPE.IN:
						return Error.new(Error.TYPE.UNEXPECTED_OPERAND, IN.Operator.Position)
					var make_var = InterpreteUnaryVertex(IN.VertexValue.left, child_storage_object)
					if make_var is Error:
						return make_var
					var List = InterpreteDataVertex(IN.VertexValue.right, child_storage_object)
					if List is Error:
						return List
					for x in List.Value:
						make_var.Value = x
						###
						var res = Interprete(vertex.VertexValue.right.VertexValue.instructions, child_storage_object)
						if res is Error:
							match res.Type:
								Error.TYPE.BREAK:
									break
								Error.TYPE.CONTINUE:
									continue
								Error.TYPE.RETURN:
									breakpoint
							return res
				'While':
					var while_key = InterpreteVertex(vertex.VertexValue.left.VertexValue, child_storage_object)
					if while_key is Error:
						return while_key
					while while_key.Value:
						var res = Interprete(vertex.VertexValue.right.VertexValue.instructions, child_storage_object)
						while_key = InterpreteVertex(vertex.VertexValue.left.VertexValue, child_storage_object)
						if while_key is Error:
							return while_key
						if res is Error:
							match res.Type:
								Error.TYPE.BREAK:
									break
								Error.TYPE.CONTINUE:
									continue
								Error.TYPE.RETURN:
									breakpoint
							return res
				'Match':
					var match_value = InterpreteVertex(vertex.VertexValue.left.VertexValue, child_storage_object)
					if match_value is Error:
						return match_value
					var instructions = null
					for case in vertex.VertexValue.right.VertexValue.instructions:
						if case.VertexValue.left.VertexValue is String:
							instructions = case.VertexValue.right.VertexValue.instructions
							break
						else:
							if case.VertexValue.left.VertexValue.VertexValue == match_value.Value:
								instructions = case.VertexValue.right.VertexValue.instructions
								break
					var res = Interprete(instructions, child_storage_object)
					if res is Error:
						return res
				_:
					breakpoint
		_:
			print(vertex)
			breakpoint

func InterpreteUnaryVertex(vertex:UnaryOperatorVertex, StorageObject:Storage):
	if vertex.Operator is OperatorToken:
		match vertex.Operator.OperatorType:
			OperatorToken.OPERATORTYPE.NOT:
				var Operand = InterpreteVertex(vertex.VertexValue, StorageObject)
				if Operand is Error:
					return Operand
				return DataOperator.negate(Operand)
			OperatorToken.OPERATORTYPE.SUBTRACT:
				var Operand = InterpreteVertex(vertex.VertexValue, StorageObject)
				if Operand is Error:
					return Operand
				return DataOperator.negate(Operand)
			OperatorToken.OPERATORTYPE.ADD:
				var Operand = InterpreteVertex(vertex.VertexValue, StorageObject)
				if Operand is Error:
					return Operand
				return Operand
			_:
				print(vertex)
				breakpoint
				return Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position)
	elif vertex.Operator is KeywordToken:
		match vertex.Operator.TokenValue:
			DataToken.DATATYPE.VARIANT, DataToken.DATATYPE.BOOLEAN, DataToken.DATATYPE.INTEGER, DataToken.DATATYPE.FLOAT, DataToken.DATATYPE.STRING, DataToken.DATATYPE.LIST, DataToken.DATATYPE.DICTIONARY, DataToken.DATATYPE.ENUMERATION, DataToken.DATATYPE.OBJECT:
				if StorageObject.has_variable(vertex.VertexValue.VertexValue):
					return Error.new(Error.TYPE.ALREADY_DEFINED_IDENTIFIER, vertex.Position)
				else:
					return StorageObject.create_variable(vertex.VertexValue.VertexValue, MarbleData.new(vertex.Operator.TokenValue))
			'Return':
				if StorageObject.function_child:#StorageObject.Parent and StorageObject.has_variable('Return'):
					var ret = InterpreteVertex(vertex.VertexValue, StorageObject)
					if ret is Error:
						return ret
					var Left = StorageObject.get_variable('Return')
					var Right = ret
					if Left.Type == DataToken.DATATYPE.VARIANT:
						Left.Value = Right.Value
					else:
						if Left.Type == Right.Type:
							Left.Value = Right.Value
						else:
							var conv = DataOperator.try_convert(Right, Left.Type)
							if conv:
								if Left.Type == DataToken.DATATYPE.OBJECT:
									Left.Value = MarbleObject.new(null)
								else:
									Left.Value = conv.Value
							else:
								return Error.new(Error.TYPE.DATATYPE_MISMATCH, vertex.VertexValue.Position)
					return Error.new(Error.TYPE.RETURN, vertex.Position)
				else:
					return Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Operator.Position)
			_:
				print(vertex)
				breakpoint
				return Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position)

func InterpreteKeywordVertex(vertex:KeywordVertex, StorageObject:Storage):
	match vertex.Keyword:
		KeywordToken.KEYWORD.FLOWCONTROL:
			match vertex.VertexValue:
				'Break':
					if StorageObject.Parent:
						return Error.new(Error.TYPE.BREAK, vertex.Position)
					else:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position)
				'Continue':
					if StorageObject.Parent:
						return Error.new(Error.TYPE.CONTINUE, vertex.Position)
					else:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position)
				'Breakpoint':
					breakpoint
				_:
					breakpoint

func Interprete(Parsed:Array, StorageObject:Storage = Storage.new()):
	for vertex in Parsed:
		if not StorageObject.Parent:
			#print(vertex)
			pass
		var Result = InterpreteVertex(vertex, StorageObject)
		if Result is Error:
			if StorageObject.Parent or StorageObject.function_child:
				match Result.Type:
					Error.TYPE.BREAK, Error.TYPE.CONTINUE:
						breakpoint
					Error.TYPE.RETURN:
						return StorageObject.get_variable('Return')
				return Result
			else:
				match Result.Type:
					Error.TYPE.BREAK, Error.TYPE.CONTINUE, Error.TYPE.RETURN:
						return Error.new(Error.TYPE.UNEXPECTED_TOKEN, vertex.Position)
					_:
						return Result
		
	if not StorageObject.Parent:
		print(StorageObject)
	return Output
