import Foundation

typealias char = UInt8
let editorConfig = EditorConfig()

func main() -> Int {

    let editor = Editor(config: editorConfig)
    let terminal = Terminal()
    
    terminal.enter(mode: .raw)
    
    while true {
        
        editor.refreshScreen()
        editor.processKeyPress()
    }

    return 0
}

_ = main()
