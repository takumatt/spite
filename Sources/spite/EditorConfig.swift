//
// Created by Takuma Matsushita on 2020/05/09.
//

import Foundation

class EditorConfig {
    
    var cx, cy: Int
    
    var screenSize: (rows: UInt16, cols: UInt16)
    var original_termios: termios? = nil
    
    var row: [EditorRow] = []
    var offset = 0

    init() {
        
        (cx, cy) = (0, 0)
        
        if let size = Terminal.getWindowSize() {
            self.screenSize = size
        } else {
            self.screenSize = (0, 0)
            Terminal.die(description: "getWindowSize")
        }
    }
    
    // TODO: move
    
    func exitWith(code: Int32) {
        
        write(STDOUT_FILENO, "\u{1b}[2J", 4)
        write(STDOUT_FILENO, "\u{1b}[H", 3)
        
        self.enterCookedMode()
        
        exit(code)
    }
    
    private func enterCookedMode() {
        
        guard self.original_termios != nil else { return }
        
        if tcsetattr(STDIN_FILENO, TCSAFLUSH, &self.original_termios!) == -1 {
            Terminal.die(description: "tcsetattr")
        }
        
        self.original_termios = nil
    }
}
