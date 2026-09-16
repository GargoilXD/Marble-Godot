# Marble-Godot

A verbose and simple programming language hobby project, implemented in GDScript with an in-Godot IDE.

> Status: early prototype. The language, standard library, and IDE are all subject to change. This is the original implementation of Marble; active language evolution now happens in the sister implementation, [Marble-Sharp](https://github.com/GargoilXD/Marble-Sharp).

## What is Marble?

Marble is a small, explicitly typed, imperative language designed to read like prose. Variables, functions, and classes are declared with full words (`Integer`, `Function`, `Class`, `For`, `Return`) rather than symbols or abbreviations.

This repo hosts the GDScript implementation: tokenizer, parser, tree interpreter, and a Godot editor UI that exposes each pipeline stage.

## Features

- Hand-written tokenizer (`Modules/Scripts/Tokenizer.gd`)
- Recursive parser producing `Vertex` trees (`Modules/Scripts/Parser.gd`)
- Tree-walking interpreter with `await`-based `Input()` (`Modules/Scripts/Interpreter.gd`)
- IDE scene with code editor, per-stage output tabs, and syntax highlighting (`Source code/InstructionProcessor.tscn`)
- Staged execution: stop after tokenize, parse, or interpret
- Persistent editor state via `Configurations/Save_data.tres` (`Ctrl+S` to save)
- Sample programs in `Programs/`

## Requirements

- Godot 4.2 (standard, non-.NET build is enough for this repo)
- `GL Compatibility` renderer (set in `project.godot`)

## Quickstart

1. Clone the repo.
2. Open `project.godot` in Godot 4.2.
3. Press `F5` to run the main scene (`res://Source code/InstructionProcessor.tscn`).
4. Paste a sample from `Programs/` into the editor and press `Run`.
5. Use the option button to set `Stop_at` (`TOKENIZER`, `PARSER`, `INTERPRETER`) and inspect each tab.

Keyboard:

- `Ctrl+S`: save current editor text and `Stop_at` selection to `Configurations/Save_data.tres`
- `Run`: tokenize, parse, then interpret
- `Clear`: clear all three output panes

## Example

From `Programs/Quadder.txt` (quadratic formula):

```
Integer A = 1
Integer B = 6
Integer C = 8
Float D = B * B - 4 * A * C

Variant X1 = 0
Variant X2 = 0
if(D > 0){
	X1 = (-B - D ^ 0.5)/(2 * A)
	X2 = (-B + D ^ 0.5)/(2 * A)
}
elseif(D == 0){
	X1 = -B/(2 * A)
	X2 = X2
}
else{
	X1 = -B/(2 * A) + " - " + (-D ^ 0.5)/(2 * A) + "i"
	X2 = -B/(2 * A) + " + " + (-D ^ 0.5)/(2 * A) + "i"
}
Print("X1: ", X1, "X2: ", X2)
```

From `Programs/Test.txt` (functions and loops):

```
List Numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]

Function Integer Sum(List Numbers) {
	Integer Summation = 0
	For Integer number in Numbers {
		Summation += number
	}
	Return Summation
}

Integer Result = Sum(Numbers)
Print(Result)
```

More samples: `Programs/GuessingGame.txt`, `Programs/AddWithMultiply.txt`, `Programs/Functionality Tests/` (`Variables.txt`, `Loops.txt`, `Functions.txt`, `Classes.txt`, `Branching.txt`).

## Project structure

```
.
├── project.godot                  # Godot 4.2, main scene: Source code/InstructionProcessor.tscn
├── Source code/
│   ├── InstructionProcessor.gd    # IDE controller: Run, Display_data, highlighting, save
│   └── InstructionProcessor.tscn  # Editor + TabContainer (Tokenizer / Parser / Interpreter)
├── Modules/
│   ├── Scripts/
│   │   ├── Tokenizer.gd           # Lexer
│   │   ├── Parser.gd              # Token -> Vertex tree
│   │   └── Interpreter.gd         # Vertex tree walker
│   └── DataStructures/
│       ├── Token/                 # Token, DataToken, KeywordToken, OperatorToken, TokenPosition
│       ├── Vertex/                # Vertex, DataVertex, KeywordVertex, OperatorVertex (+ Unary/Binary)
│       ├── IntepreterData/        # MarbleData, MarbleObject, MarbleFunction, MarbleEnumeration, InterpreterOutput
│       └── Error.gd               # Tokenizer / parser / interpreter errors with position
├── Configurations/
│   ├── SaveData.gd                # Resource: Code + Stop_at
│   └── Save_data.tres             # Persisted editor state
├── Programs/                      # Sample Marble programs (.txt)
├── Tests/
│   ├── QuickTest.gd               # EditorScript stub
│   ├── SlowTest.gd
│   └── SlowTest.tscn
└── Assets/                        # Icons, fonts
```

Note: `Source code/ins*.tmp` and `.godot/` are local editor artifacts, not part of the language.

## How it works

1. **Tokenize.** `Tokenizer.Tokenize(code)` scans the editor text into `Token`s. Keywords are matched case-sensitively (see table below). Failure returns an `Error` with a `TokenPosition`, displayed in the Tokenizer tab.
2. **Parse.** `Parser.Parse(tokens)` builds `Vertex` nodes (`DataVertex`, `KeywordVertex`, `OperatorVertex`, etc.). Failure is shown in the Parser tab.
3. **Interpret.** `Interpreter.Interprete(vertexes)` walks the tree and appends to `Interpreter.Output`, shown in the Interpreter tab. `Input()` pauses on an `AcceptDialog` for user entry.

The `Stop_at` option short-circuits after the selected stage so you can debug lexing and parsing independently.

## Language cheat-sheet (this repo)

Comments use `#`:

```
# this is a comment #
```

Literals: `"double"` or `'single'` strings, integers, floats, `true` / `false` / `null` / `self`.

| Category | Keywords |
|---|---|
| Modifiers | `Const`, `Static`, `Public`, `Private`, `Void` |
| Datatypes | `Variant`, `Boolean`, `Integer`, `Float`, `String`, `List`, `Dictionary`, `Enumeration`, `Object` |
| Definitions | `Class`, `Function` |
| Loops | `For`, `While` |
| Decisions | `if`, `else`, `elseif`, `Match`, `Case`, `Default` |
| Flow control | `Break`, `Continue`, `Return`, `Breakpoint` |
| Operators (word) | `not`, `and`, `or`, `in`, `is`, `extends` |
| Builtins | `Assert`, `Print`, `Range`, `Random`, `Input` |

Symbolic operators: `+ - * / ^ % = < > : . & |` and `!= += -= *= /= ^= %= == <= >=`. `^` is exponent. Newlines are significant (`END_OF_LINE` tokens).

Minimal class example from `Programs/Functionality Tests/Classes.txt`:

```
Class Animal{
	String Name = ''
}

Class Cat extends Animal{
	String Age = 0
}
```

## Testing

- `Tests/QuickTest.gd`: `EditorScript` stub, currently empty.
- `Tests/SlowTest.gd` / `SlowTest.tscn`: scene-attached scratch test.
- `Programs/Functionality Tests/`: the de facto test corpus (variables, loops, functions, classes, branching). Run each file through the IDE and check the Interpreter tab.

There is no automated test runner yet. Per project baseline, the next step would be unit tests for the tokenizer/parser plus full-stack runs of `Programs/` against expected outputs.

## Roadmap / limitations

- No package manager, module imports, or file I/O beyond the editor
- Error messages carry positions but no recovery or multi-error reporting
- `MarbleEnumeration` file has a naming typo on disk (`MarbleEnumerationgd` duplicate); parser behavior for enumerations is incomplete
- `Tests/` are stubs; `Programs/` are the real coverage
- Active language evolution happens in [Marble-Sharp](https://github.com/GargoilXD/Marble-Sharp) (lowercase syntax, C# backend)

## Contributing

Small hobby project. Keep changes minimal and match the surrounding GDScript style (tabs, `PascalCase` keywords, `class_name` per type). If you add syntax, add a sample under `Programs/Functionality Tests/` showing it running.

## License

MIT — see `LICENSE` (to be added; intended license is MIT). No credentials are stored in this repo; local state lives in `Configurations/Save_data.tres`.
