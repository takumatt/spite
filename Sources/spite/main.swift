import Foundation

typealias char = UInt8

let editorConfig = EditorConfig(
    size: Terminal.getWindowSize() ?? (0, 0)
)

func main() -> Int {

    let terminal = Terminal()

    terminal.enter(mode: .raw)
    
    let editor = Editor()
    
    while true {
        
        editor.refreshScreen()
        editor.processKeyPress()
    }

    return 0
}

_ = main()
