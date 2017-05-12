//
// Lexer.swift
// Author: Alexey Komnin
//

import Foundation

extension ASCII {
    func isValidIdentifierBody() -> Bool {
        return isCharacter() || isDigit() || self == .DOL || self == .USCR
    }
    
    func isValidOperatorBody() -> Bool {
        switch self {
        case .BSLSH, .EQ, .MNS, .PLS, .STAR, .PERC, .LT,
             .GT, .EMARK, .AMP, .VL, .CAR, .TLD, .DOT,
             .QMARK: // /=-+*%<>!&|^~.?
            return true
            
        default:
            return false
        }
    }
}

// I would start with definition of the Lexer. It must hold the buffer - a content string, cursor to the current position in that buffer, and NextToken for lookahead peeking. So, it's the minimal definition, I assume.
public class Lexer {
    private var NextToken: Token
    private var Cursor: DataCursor
    
    // Next step is to define a simple initializer. Note that we must condume the first pack of characters due to initialization and place valid token into NextToken property.
    public init(content: Data) {
        Cursor = DataCursor(content: content)
        NextToken = .NUM_TOKENS
        
        // lexImpl() routine would be our main lexer loop followin the original implementation in Lexer.cpp.
        lexImpl()
    }
    
    // Also, we can define lex() and peekNextToken() routines - API for future Parser.
    public func lex(Result: inout Token) {
        Result = NextToken
        if Result != .EOF {
            lexImpl()
        }
    }
    public func peekNextToken() -> Token {
        return NextToken
    }
    
    // Ok. Preparation is over. We proceed with implementation of the main lexer loop, which is just a big switch statement.
    private func lexImpl() {
        // It consist of:
        // 0. Prologue
        while !Cursor.atEnd() {
            switch Cursor.consume() {
                
            // 1. consume all whitespace characters
            case .LF, .CR, .TAB, .SPACE, .FF, .VT:
                break
                
                // 2. Null
                // We won't treat null in the middle of the buffer as a whitespace.
            // Define it as an error instead. Otherwise, lexer must generate EOF token
            case .NUL:
                fatalError("Unexpected null character")
                
            // 3. Brackets, colons etc.
            case .AT:
                NextToken = .AtSign
                return
                
            case .LBR:
                NextToken = .Lbrace
                return
            case .LSQ:
                NextToken = .Lsquare
                return
            case .LPAR:
                NextToken = .Lparen
                return
                
            case .RBR:
                NextToken = .Rbrace
                return
            case .RSQ:
                NextToken = .Rsquare
                return
            case .RPAR:
                NextToken = .Rparen
                return
                
            case .COM:
                NextToken = .Comma
                return
            case .SEM:
                NextToken = .Semi
                return
            case .COL:
                NextToken = .Colon
                return
                
                // 4. Literlas.
                // as mentioned earlier, there are three types of literals in Swift:
                //   * Boolean literals
                //   * String literals
                //   * Number literlas
                // Lexer may produce tokens only for two of them: boolean literlas are consumed as identifiers and processed later by top-
                // level parser.
                
                
            // 4.1. Numbers
            case ASCII.NUM0...ASCII.NUM9:
                lexNumber()
                return
                
            // 4.2. Strings
            case .DQUOT:
                lexStringLiteral()
                return
                
                // 5. Identifiers.
                // There are three types of identifiers at lexer stage:
                // * Dollar identifier ($0, $1 etc.)
                // * Operator identifier
            // * C-like identifiers
            case .DOL:
                lexDollarIdent()
                return
                
            case .CHR_a, .CHR_b, .CHR_c, .CHR_d, .CHR_e, .CHR_f, .CHR_g, .CHR_h, .CHR_i,
                 .CHR_j, .CHR_k, .CHR_l, .CHR_m, .CHR_n, .CHR_o, .CHR_p, .CHR_q, .CHR_r,
                 .CHR_s, .CHR_t, .CHR_u, .CHR_v, .CHR_w, .CHR_x, .CHR_y, .CHR_z,
                 .CHR_A, .CHR_B, .CHR_C, .CHR_D, .CHR_E, .CHR_F, .CHR_G, .CHR_H, .CHR_I,
                 .CHR_J, .CHR_K, .CHR_L, .CHR_M, .CHR_N, .CHR_O, .CHR_P, .CHR_Q, .CHR_R,
                 .CHR_S, .CHR_T, .CHR_U, .CHR_V, .CHR_W, .CHR_X, .CHR_Y, .CHR_Z,
                 .USCR:
                lexIdentifier()
                return
                
            // Operator characters.
            case .BSLSH:
                switch Cursor.consume() {
                case .BSLSH:
                    skipSlashSlashComment()
                    break
                case .STAR:
                    skipSlashStarComment()
                    break
                default:
                    lexOperatorIdentifier()
                    return
                }
                
            case .PERC, .EMARK, .QMARK, .LT, .GT, .EQ,
                 .MNS, .PLS, .STAR, .AMP, .VL, .CAR, .TLD,
                 .DOT:
                lexOperatorIdentifier()
                return
                
            default:
                NextToken = .Unknown
                return
            }
        }
        
        // We must define the point where lexer responds with EOF
        assert(Cursor.atEnd())
        NextToken = .EOF
    }
    
    private func skipSlashSlashComment() {
        while !Cursor.atEnd() && Cursor.consume() != .LF {}
    }
    
    /// skipSlashStarComment - /**/ comments are skipped (treated as whitespace).
    /// Note that (unlike in C) block comments can be nested.
    private func skipSlashStarComment() {
        // Make sure to advance over the * so that we don't incorrectly handle /*/ as
        // the beginning and end of the comment.
        Cursor.move()
        
        // /**/ comments can be nested, keep track of how deep we've gone.
        var Depth = 1;
        
        while true {
            switch Cursor.consume() {
            case .STAR:
                // Check for a '*/'
                if Cursor.get() == .BSLSH {
                    Cursor.move()
                    Depth -= 1
                    if Depth == 0 {
                        return
                    }
                }
                
            case .BSLSH:
                // Check for a '/*'
                if Cursor.get() == .STAR {
                    Cursor.move()
                    Depth += 1
                }
                
            case .LF, .CR: break
            case .NUL:
                // If this is a random nul character in the middle of a buffer, skip it as
                // whitespace.
                if !Cursor.atEnd() {
                    // Diagnose lex_nul_character
                    break
                }
                
                // Otherwise, we have an unterminated /* comment.
                // throw lex_unterminated_block_comment
                return
                
            default:
                break   // eat other characters.
            }
        }
    }
    
    /// lexDollarIdent - Match $[0-9a-zA-Z_$]+
    private func lexDollarIdent() {
        var length = 0
        while Cursor.get().isDigit() {
            length += 1
            Cursor.move()
        }
        
        Cursor.move(direction: .Backward, count: length)
        let identifier = String(bytes: Cursor.consumeBytes(count: length), encoding: .utf8)!
        guard !identifier.isEmpty else {
            // TODO: throw invalid_dollar_ident
            NextToken = .Unknown
            return
        }
        
        NextToken = .DollarIdent(identifier)
    }
    
    // Now it is time to find out how string literals are consumed.
    /// lexStringLiteral:
    ///   string_literal ::= ["]([^"\\\n\r]|character_escape)*["]
    private func lexStringLiteral() {
        var unicodeSequence = [UInt32]()
        
        // The loop is intended to consume characters untill the enclosing quote is found.
        while true {
            // As usual, the routine starts with some error handling logic.
            
            // String literals cannot have \n or \r in them.
            guard Cursor.get() != .LF || Cursor.get() != .CR else {
                // TODO: raise "Unterminated String" exception
                NextToken = .Unknown
                return
            }
            
            let CharValue = lexUnicodeScalar(cursor: &Cursor)
            
            if CharValue == ~1 {
                NextToken = .Unknown
                return
            }
            
            if CharValue == ~0 {
                Cursor.move()
                NextToken = .StringLiteral(String(unicodeSequence.flatMap(UnicodeScalar.init).map(Character.init)))
                return
            }
            else {
                unicodeSequence.append(CharValue)
            }
        }
    }
    
    private func lexNumber() {
        Cursor.move(direction: .Backward)
        var TokStart = Cursor
        Cursor.move()
        
        if TokStart.get() == .NUM0 && Cursor.get() == .CHR_x {
            lexHexNumber()
            return
        }
        
        if TokStart.get() == .NUM0 && Cursor.get() == .CHR_o {
            // 0o[0-7][0-7_]*
            var literalLength = 0
            Cursor.move()
            let characterRange = ASCII.NUM0...ASCII.NUM7
            guard characterRange.contains(Cursor.get()) else {
                fatalError("Expected digit in int literal")
            }
            while characterRange.contains(Cursor.get()) || Cursor.get() == .USCR {
                literalLength += 1
                Cursor.move()
            }
            NextToken = .IntegerLiteral(String(bytes: TokStart.consumeBytes(count: literalLength), encoding: .utf8)!)
            return
        }
        
        if TokStart.get() == .NUM0 && Cursor.get() == .CHR_b {
            // 0b[01][01_]*
            var literalLength = 0
            Cursor.move()
            guard Cursor.get() == .NUM0 || Cursor.get() == .NUM1 else {
                fatalError("Expected digit in int literal")
            }
            while Cursor.get() == .NUM0 || Cursor.get() == .NUM1 || Cursor.get() == .USCR {
                literalLength += 1
                Cursor.move()
            }
            NextToken = .IntegerLiteral(String(bytes: TokStart.consumeBytes(count: literalLength), encoding: .utf8)!)
            return
        }
        
        // Handle a leading [0-9]+, lexing an integer or falling through if we have a
        // floating point value.
        var literalLength = 0
        while Cursor.get().isDigit() || Cursor.get() == .USCR {
            literalLength += 1
            Cursor.move()
        }
        
        // Lex things like 4.x as '4' followed by a tok::period.
        if Cursor.get() == .DOT {
            // NextToken is the soon to be previous token
            // Therefore: x.0.1 is sub-tuple access, not x.float_literal
            Cursor.move()
            let character = Cursor.get()
            Cursor.move(direction: .Backward)
            if !character.isDigit() || NextToken == .OpPeriod {
                NextToken = .IntegerLiteral(String(bytes: TokStart.consumeBytes(count: literalLength), encoding: .utf8)!)
                return
            }
        } else {
            // Floating literals must have '.', 'e', or 'E' after digits.  If it is
            // something else, then this is the end of the token.
            if Cursor.get() != .CHR_e && Cursor.get() != .CHR_E {
                NextToken = .IntegerLiteral(String(bytes: TokStart.consumeBytes(count: literalLength), encoding: .utf8)!)
                return
            }
        }
        
        // Lex decimal point.
        if Cursor.get() == .DOT {
            Cursor.move()
            
            // Lex any digits after the decimal point.
            while Cursor.get().isDigit() || Cursor.get() == .USCR {
                literalLength += 1
                Cursor.move()
            }
        }
        
        // Lex exponent.
        if Cursor.get() == .CHR_E || Cursor.get() == .CHR_e {
            literalLength += 1
            Cursor.move()
            
            if Cursor.get() == .PLS || Cursor.get() == .MNS {
                literalLength += 1
                Cursor.move()
            }
            
            guard Cursor.get().isDigit() else {
                fatalError("Expected digit in fp component")
            }
            
            while Cursor.get().isDigit() || Cursor.get() == .USCR {
                literalLength += 1
                Cursor.move()
            }
        }
        
        NextToken = .FloatingLiteral(String(bytes: TokStart.consumeBytes(count: literalLength), encoding: .utf8)!)
    }
    
    private func lexHexNumber() {
        
    }
    
    /// lexUnicodeScalar - Read a character and return its UnicodeScalar.  If this is the
    /// end of enclosing string/character sequence (i.e. the character is equal to
    /// 'StopQuote'), this returns ~0U and leaves 'Cursor' pointing to the terminal
    /// quote.  If this is a malformed character sequence, it returns ~1U.
    ///
    ///   character_escape  ::= [\][\] | [\]t | [\]n | [\]r | [\]" | [\]' | [\]0
    ///   character_escape  ::= unicode_character_escape
    private func lexUnicodeScalar(cursor: inout DataCursor) -> UInt32 {
        let character = cursor.get()
        cursor.move()
        
        switch character {
        case .DQUOT:
            // If we found a closing quote character, we're done.
            cursor.move()
            return ~0
        case .NUL:
            return 0
        case .LF, .CR:
            // String literals cannot have \n or \r in them.
            return ~1
        case .SLSH:
            // Escapes.
            break
        default:
            return numericCast(character.rawValue)
        }
        
        switch cursor.get() {
        case .NUM0:
            cursor.move()
            return 0
        case .CHR_n:
            cursor.move()
            return numericCast(ASCII.LF.rawValue)
        case .CHR_r:
            cursor.move()
            return numericCast(ASCII.CR.rawValue)
        case .CHR_t:
            cursor.move()
            return numericCast(ASCII.TAB.rawValue)
        case .DQUOT:
            cursor.move()
            return numericCast(ASCII.DQUOT.rawValue)
        case .SQUOT:
            cursor.move()
            return numericCast(ASCII.SQUOT.rawValue)
        case .SLSH:
            cursor.move()
            return numericCast(ASCII.SLSH.rawValue)
        case .CHR_u:
            // \u HEX HEX HEX HEX
            cursor.move()
            guard cursor.get() == .LBR else {
                return ~1
            }
            
            return lexUnicodeEscape(cursor: &cursor)
            
        default:
            // Invalid escape.
            // TODO: throw "Invalid escape"
            return ~1
        }
    }
    
    ///   unicode_character_escape ::= [\]u{hex+}
    ///   hex                      ::= [0-9a-fA-F]
    private func lexUnicodeEscape(cursor: inout DataCursor) -> UInt32 {
        cursor.move()
        
        var character = cursor.get()
        var NumDigits = 0
        while character.isHexDigit() {
            NumDigits += 1
            cursor.move()
            character = cursor.get()
        }
        
        if character != .RBR {
            // TODO: throw invalid_u_escape_rbrace
            return ~1
        }
        
        
        
        if NumDigits < 1 || NumDigits > 8 {
            // TODO: throw invalid_u_escape
            return ~1
        }
        
        cursor.move(direction: .Backward, count: NumDigits)
        let bytes = cursor.consumeBytes(count: NumDigits)
        // consume }
        cursor.move()
        
        return UInt32(String(bytes: bytes, encoding: .utf8)!, radix: 16) ?? 0
    }
    
    /// lexIdentifier - Match [a-zA-Z_][a-zA-Z_$0-9]*
    private func lexIdentifier() {
        var identifierLength = 1
        while Cursor.get().isValidIdentifierBody() {
            identifierLength += 1
            Cursor.move()
        }
        Cursor.move(direction: .Backward, count: identifierLength)
        let identifier = String(bytes: Cursor.consumeBytes(count: identifierLength),
                                encoding: .utf8)!
        NextToken = Token(identifier: identifier)
    }
    
    /// lexOperatorIdentifier - Match identifiers formed out of punctuation.
    private func lexOperatorIdentifier() {
        var identifierLength = 1
        while Cursor.get().isValidOperatorBody() {
            identifierLength += 1
            Cursor.move()
        }
        
        // Decide between the binary, prefix, and postfix cases.
        // It's binary if either both sides are bound or both sides are not bound.
        // Otherwise, it's postfix if left-bound and prefix if right-bound.
        
        Cursor.move(direction: .Backward, count: identifierLength + 1)
        let isLeftBound: Bool = {
            switch Cursor.get() {
            case .SPACE, .CR, .LF, .TAB, // whitespace
            .LBR, .LSQ, .LPAR,      // opening delimiters
            .COM, .SEM, .COL,       // expression separators
            .NUL:
                return false
                
            default:
                return true
            }
        }()
        Cursor.move()
        let identifier = String(bytes: Cursor.consumeBytes(count: identifierLength),
                                encoding: .utf8)!
        
        let isRightBound: Bool = {
            switch Cursor.get() {
            case .SPACE, .CR, .LF, .TAB, // whitespace
            .RBR, .RSQ, .RPAR,      // closing delimiters
            .COM, .SEM, .COL,       // expression separators
            .NUL:
                return false
                
            case .DOT:
                // Prefer the '^' in "x^.y" to be a postfix op, not binary, but the '^' in
                // "^.y" to be a prefix op, not binary.
                return !isLeftBound
                
            default:
                return true
            }
        }()
        
        // Match various reserved words.
        switch identifier {
        case "=":
            assert(isLeftBound == isRightBound)
            NextToken = .OpEqual
            return
            
        case "&":
            guard isRightBound && !isLeftBound else {
                break
            }
            NextToken = .OpAmpPrefix
            return
            
        case ".":
            if isLeftBound == isRightBound {
                NextToken = .OpPeriod
            }
            else if isRightBound {
                NextToken = .OpPeriodPrefix
            }
            else {
                // Otherwise, it is probably a missing member.
                NextToken = .Unknown
            }
            return
            
        case "?":
            NextToken = isLeftBound ? .OpQuestionPostfix : .OpQuestionInfix
            return
            
        case "->":
            NextToken = .OpArrow
            return
            
        default:
            break
        }
        
        if isLeftBound == isRightBound {
            NextToken = isLeftBound ? .OpBinaryUnspaced(identifier) : .OpBinarySpaced(identifier)
        }
        else {
            NextToken = isLeftBound ? .OpPostfix(identifier) : .OpPrefix(identifier)
        }
    }
}

