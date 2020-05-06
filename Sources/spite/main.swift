import Foundation

typealias char = UInt8

func main() -> Int {

    let terminal = Terminal()
    
    print("Hello.")
    
    terminal.enter(mode: .raw)
    
    let editor = Editor()
    
    while true {
        
        editor.refreshScreen()
        editor.processKeyPress()
    }
    
    print("Bye!")

    return 0
}

_ = main()
