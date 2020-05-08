//
// Created by Takuma Matsushita on 2020/05/09.
//

import Foundation

class EditorConfig {

    var screenSize: (UInt16, UInt16)
    var original_termios: termios? = nil

    init(size: (UInt16, UInt16)) {
        self.screenSize = size
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
