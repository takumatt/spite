import Foundation

typealias char = UInt8
let stdio = FileHandle.standardInput

func main() -> Int {

    let terminal = Terminal()
    
    print("Hello.")
    
    terminal.enter(mode: .raw)
    
    let editor = Editor()
    
    while true {
        
        editor.processKeyPress()
    }
    
    print("Bye!")

    return 0
}

_ = main()
