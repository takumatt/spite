import Foundation

typealias char = UInt8
let editorConfig = EditorConfig()

func main() -> Int {

    let terminal = Terminal()
    let editor = Editor(config: editorConfig)
    
    terminal.enter(mode: .raw)
    
    while true {
        
        editor.refreshScreen()
        editor.processKeyPress()
    }

    return 0
}

_ = main()
