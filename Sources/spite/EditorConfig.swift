//
// Created by Takuma Matsushita on 2020/05/09.
//

import Foundation

class EditorConfig {

    var screenSize: (rows: UInt16, cols: UInt16)
    var original_termios: termios? = nil

    init() {
        
        if let size = Terminal.getWindowSize() {
            self.screenSize = size
        } else {
            self.screenSize = (0, 0)
            Terminal.die(description: "getWindowSize")
        }
    }
    
    func exitWith(code: Int32) {
        
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
