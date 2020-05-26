import Foundation

// TODO: move
let SPITE_VERSION = "0.0.1"

typealias char = UInt8
let editorConfig = EditorConfig()

func main() -> Int {

    let editor = Editor(config: editorConfig)
    let terminal = Terminal()
    
    terminal.enter(mode: .raw)
    
    editor.open()
    
    while true {
        
        editor.refreshScreen()
        editor.processKeyPress()
    }

    return 0
}

_ = main()
