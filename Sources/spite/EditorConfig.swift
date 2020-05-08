//
// Created by Takuma Matsushita on 2020/05/09.
//

import Foundation

class EditorConfig {

    var original_termios: termios? = nil

    init() { }
    
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
