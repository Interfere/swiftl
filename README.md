# Swift Lexer

Here is a dummy implementation of Swift lexer writter in pure swift.

## Example
```
Usage: swiftl [FILENAME]
```
Simply pass swift source as a first argument. The lexer will paste the token sequence into stdout.

```
~$ cat A.swift
import Foundation

extension CGRect {
    /// Creates a rect with unnamed arguments.
    public init(_ origin: CGPoint, _ size: CGSize) {
        self.origin = origin
        self.size = size
    }
...
}

~$ swiftl A.swift > A.tokens
~$ cat A.tokens
KW_import Identifier("Foundation")

KW_extension Identifier("CGRect") Lbrace 
  KW_public KW_init Lparen KW__ Identifier("origin") Colon Identifier("CGPoint") Comma KW__ Identifier("size") Colon Identifier("CGSize") Rparen Lbrace
    KW_self OpPeriod Identifier("origin") OpEqual Identifier("origin")
    KW_self OpPeriod Identifier("size") OpEqual Identifier("size") 
  Rbrace 
...
Rbrace EOF
```

## Installation
### Swift Package
```swift
.package(url: "https://github.com/interfere/swiftl.git", from: "1.0.0")
```

### Manually
Build sources using `xcodebuild`. No additional dependencies.

## License 
swiftl is available under the MIT license. See the [LICENSE](https://github.com/interfere/swiftl/blob/master/LICENSE) file for more info.

