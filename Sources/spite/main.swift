import Foundation

// TODO: move
let SPITE_VERSION = "0.0.1"
let SPITE_TAB_STOP = 8

typealias char = UInt8
let editorConfig = EditorConfig()

func main() -> Int {
  
  let editor = Editor(config: editorConfig)
  let terminal = Terminal()
  
  terminal.enter(mode: .raw)
  
  if CommandLine.argc >= 2 {
    do {
      try editor.open(path: CommandLine.arguments[1])
    } catch {
      Terminal.die(description: "fopen")
    }
  }
  
  editor.setStatusMessage(text: "HELP: Ctrl-Q = quit")
  
  while true {
    
    editor.refreshScreen()
    editor.processKeyPress()
  }
  
  return 0
}

_ = main()
