//
// Token.swift
// Author: Alexey Komnin
//

// I start with implementing lexer in the same order, as I were overviewing it.
// First of all we define Token enum which. Put some predefined valus in it: EOF and NUM_TOKENS. I'll put new cases due to moving further with Lexer implementation.
public enum Token: Equatable {
    case Unknown
    
    case AtSign
    
    case Lbrace
    case Rbrace
    
    case Lsquare
    case Rsquare
    
    case Lparen
    case Rparen
    
    case Comma
    case Semi
    case Colon
    
    case StringLiteral(String)
    case IntegerLiteral(String)
    case FloatingLiteral(String)
    
    case DollarIdent(String)
    case Identifier(String)
    
    /// Operators
    case OpPrefix(String)
    case OpPostfix(String)
    case OpBinaryUnspaced(String)
    case OpBinarySpaced(String)
    
    case OpEqual
    case OpAmpPrefix
    case OpPeriod
    case OpPeriodPrefix
    case OpQuestionPostfix
    case OpQuestionInfix
    case OpArrow
    
    /// Keywords
    /// Decl keywords
    case KW_associatedtype
    case KW_class
    case KW_deinit
    case KW_enum
    case KW_extension
    case KW_func
    case KW_import
    case KW_init
    case KW_inout
    case KW_let
    case KW_operator
    case KW_precedencegroup
    case KW_protocol
    case KW_struct
    case KW_subscript
    case KW_typealias
    case KW_var
    case KW_fileprivate
    case KW_internal
    case KW_private
    case KW_public
    case KW_static
    
    /// Statement keywords.
    case KW_defer
    case KW_if
    case KW_guard
    case KW_do
    case KW_repeat
    case KW_else
    case KW_for
    case KW_in
    case KW_while
    case KW_return
    case KW_break
    case KW_continue
    case KW_fallthrough
    case KW_switch
    case KW_case
    case KW_default
    case KW_where
    case KW_catch
    
    /// Expression keywords.
    case KW_as
    case KW_Any
    case KW_false
    case KW_is
    case KW_nil
    case KW_rethrows
    case KW_super
    case KW_self
    case KW_Self
    case KW_throw
    case KW_true
    case KW_try
    case KW_throws
    
    /// Pattern keywords.
    case KW__
    
    case EOF
    case NUM_TOKENS
}

/// Parse identifiers
public extension Token {
    init(identifier: String) {
        
        switch identifier {
        /// Decl keywords
        case "associatedtype":  self = .KW_associatedtype
        case "class":           self = .KW_class
        case "deinit":          self = .KW_deinit
        case "enum":            self = .KW_enum
        case "extension":       self = .KW_extension
        case "func":            self = .KW_func
        case "import":          self = .KW_import
        case "init":            self = .KW_init
        case "inout":           self = .KW_inout
        case "let":             self = .KW_let
        case "operator":        self = .KW_operator
        case "precedencegroup": self = .KW_precedencegroup
        case "protocol":        self = .KW_protocol
        case "struct":          self = .KW_struct
        case "subscript":       self = .KW_subscript
        case "typealias":       self = .KW_typealias
        case "var":             self = .KW_var
            
        case "fileprivate":     self = .KW_fileprivate
        case "internal":        self = .KW_internal
        case "private":         self = .KW_private
        case "public":          self = .KW_public
        case "static":          self = .KW_static
            
        /// Statement keywords.
        case "defer":       self = .KW_defer
        case "if":          self = .KW_if
        case "guard":       self = .KW_guard
        case "do":          self = .KW_do
        case "repeat":      self = .KW_repeat
        case "else":        self = .KW_else
        case "for":         self = .KW_for
        case "in":          self = .KW_in
        case "while":       self = .KW_while
        case "return":      self = .KW_return
        case "break":       self = .KW_break
        case "continue":    self = .KW_continue
        case "fallthrough": self = .KW_fallthrough
        case "switch":      self = .KW_switch
        case "case":        self = .KW_case
        case "default":     self = .KW_default
        case "where":       self = .KW_where
        case "catch":       self = .KW_catch
            
        /// Expression keywords.
        case "as":          self = .KW_as
        case "Any":         self = .KW_Any
        case "false":       self = .KW_false
        case "is":          self = .KW_is
        case "nil":         self = .KW_nil
        case "rethrows":    self = .KW_rethrows
        case "super":       self = .KW_super
        case "self":        self = .KW_self
        case "Self":        self = .KW_Self
        case "throw":       self = .KW_throw
        case "true":        self = .KW_true
        case "try":         self = .KW_try
        case "throws":      self = .KW_throws
            
        /// Pattern keywords.
        case "_":           self = .KW__
            
        default: self = .Identifier(identifier)
        }
    }
}

public func ==(lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.NUM_TOKENS, .NUM_TOKENS): return true
    case (.EOF, .EOF): return true
    case (.OpPeriod, .OpPeriod): return true
    default: return false
    }
}

