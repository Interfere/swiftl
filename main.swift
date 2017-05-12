//
// main.swift
// Author: Alexey Komnin
//

// Another bit about Lexer

import Foundation

func printUsage() {
    print("Usage: swiftl [FILENAME]")
}

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    printUsage()
    exit(EXIT_FAILURE)
}

let filePath = URL(fileURLWithPath: arguments[1])
guard FileManager.default.fileExists(atPath: filePath.path) else {
    print("Unable to read a file")
    exit(EXIT_FAILURE)
}

// with that simple set of token we can check if the Lexer works as expected. Let's write a simple code containing only braces, parenthesis and whitespaces and check if it parser the input correctly.

// First, we define input and output buffer.
var output = ""
let input = try! Data(contentsOf: filePath)

// Next, we create Lexer and adjust initial state
let lexer = Lexer(content: input)
var token = Token.NUM_TOKENS

// And define the main parsing loop
while token != .EOF {
    lexer.lex(Result: &token)
    print("\(token)", terminator: " ", to: &output)
}

// And, finally, we get what we expected:
// Lbrace("{") AtSign("@") Comma(",") Colon(":") Rbrace("}") Lparen("(") Rparen(")") EOF
print(output)

