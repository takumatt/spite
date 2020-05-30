//
//  Editor.swift
//  spite
//
//  Created by Takuma Matsushita on 2020/05/06.
//

import Foundation

class Editor {
    
    struct Key {
        
        enum KeyType: Equatable {
            case alphabet(char)
            case escape
            case arrowLeft
            case arrowRight
            case arrowUp
            case arrowDown
            case delete
            case home
            case end
            case pageUp
            case pageDown
        }
        
        let type: KeyType
    }
    
    let config: EditorConfig
    
    init(config: EditorConfig) {
        self.config = config
    }
    
    func open(path: String) throws {
        
        let fileURL = URL(fileURLWithPath: path)
        
        let lines = try String(contentsOf: fileURL, encoding: .utf8)
            .components(separatedBy: .init(charactersIn: "\r\n"))
        
        lines.forEach { line in
            appendRow(line: line)
        }
    }
    
    func appendRow(line: String) {
        
        config.rows.append(.init(line: line))
    }
    
    func moveCursor(type: Key.KeyType) {
        
        switch type {
            
        case .arrowLeft:
            if config.cursor.x > 0 {
                config.cursor.x -= 1
            } else {
                guard config.cursor.y > 0 else { break }
                config.cursor.y -= 1
                config.cursor.x = config.currentRow.size
            }
            
        case .arrowRight:
            if config.cursor.x < config.currentRow.size {
                config.cursor.x += 1
            } else {
                guard config.cursor.y < config.rows.count,
                    config.cursor.x == config.currentRow.size else {
                        break
                }
                config.cursor.y += 1
                config.cursor.x = 0
            }
            
        case .arrowUp:
            guard config.cursor.y > 0 else { break }
            config.cursor.y -= 1
            
        case .arrowDown:
            guard config.cursor.y < config.rows.count - 1 else { break }
            config.cursor.y += 1
            
        case .home:
            config.cursor.x = 0
            
        case .end:
            if config.cursor.y < config.rows.count {
                config.cursor.x = Int(config.screenSize.cols - 1)
            }
            
        case .pageUp:
            config.cursor.y = config.offset.row
            (0..<Int(config.screenSize.rows)).forEach { _ in moveCursor(type: .arrowUp) }
            
        case .pageDown:
            config.cursor.y = config.offset.row + Int(config.screenSize.rows) - 1
            if config.cursor.y > config.rows.count {
                config.cursor.y = config.rows.count
            }
            (0..<Int(config.screenSize.rows)).forEach { _ in moveCursor(type: .arrowDown) }
            
        default: break
        }
        
        if config.cursor.x > config.currentRow.size {
            config.cursor.x = config.currentRow.size
        }
    }
    
    func processKeyPress() {
        
        let key = readKey()
        
        switch key.type {
            
        case .alphabet(let char):
            
            switch char {
                
            case CTRL_KEY("q"):
                editorConfig.exitWith(code: 0)
                
            case "w".char:
                moveCursor(type: .arrowUp)
            case "a".char:
                moveCursor(type: .arrowLeft)
            case "s".char:
                moveCursor(type: .arrowDown)
            case "d".char:
                moveCursor(type: .arrowRight)
                
            default:
                break
            }
            
        case .arrowLeft, .arrowRight, .arrowUp, .arrowDown,
             .pageUp, .pageDown,
             .home, .end:
            moveCursor(type: key.type)
            
        default:
            break
        }
    }
    
    func drawRows(appendBuffer ab: inout AppendBuffer) {
        
        for y in 0..<config.screenSize.rows {
            
            let row = Int(y) + config.offset.row
            
            if row >= config.rows.count {
                
                if config.rows.count == 0 && y == config.screenSize.rows / 3 {
                    
                    let message = String(
                        """
                            Spite editor --version \(SPITE_VERSION)
                            """
                            .prefix(Int(config.screenSize.cols))
                    )
                    
                    var padding = (Int(config.screenSize.cols) - message.count) / 2
                    
                    if padding > 1 {
                        ab.append("~")
                        padding -= 1
                    }
                    
                    (0..<padding).forEach { _ in ab.append(" ") }
                    
                    ab.append(message)
                } else {
                    ab.append("~")
                }
            } else {
                
                let rowChars = config.rows[Int(row)].render
                
                if rowChars.count > config.offset.col {

                    let offseted = rowChars.suffix(from: config.offset.col)
                    let chars = Array(offseted.prefix(Int(config.screenSize.cols)))
                    
                    ab.append(chars)
                } else {
                    ab.append("")
                }
            }
            
            ab.append("\u{1b}[K")
            ab.append("\r\n")
        }
    }
    
    func drawStatusBar(appendBuffer ab: inout AppendBuffer) {
        
        ab.append("\u{1b}[7m")
        
        (0..<config.screenSize.cols).forEach { _ in
            ab.append(" ")
        }
        
        ab.append("\u{1b}[m")
    }
    
    func scroll() {
        
        config.position.x = 0
        
        if config.cursor.y < config.rows.count {
            config.position.x = config.currentRow.cursorToPositionX(x: config.cursor.x)
        }
        
        if config.cursor.y < config.offset.row {
            config.offset.row = config.cursor.y
        }
        
        if config.cursor.y >= config.offset.row + Int(config.screenSize.rows) {
            config.offset.row = config.cursor.y - Int(config.screenSize.rows) + 1
        }
        
        if config.position.x < config.offset.col {
            config.offset.col = config.position.x
        }
        
        if config.position.x >= config.offset.col + Int(config.screenSize.cols) {
            config.offset.col = config.position.x - Int(config.screenSize.cols) + 1
        }
    }
    
    func refreshScreen() {
        
        scroll()
        
        var ab = AppendBuffer()
        
        ab.append("\u{1b}[?25l")
        ab.append("\u{1b}[H")
        
        drawRows(appendBuffer: &ab)
        drawStatusBar(appendBuffer: &ab)
        
        ab.append(String(
            format: "\u{1b}[%d;%dH",
            config.cursor.y - config.offset.row + 1,
            config.position.x - config.offset.col + 1
            )
        )
        
        ab.append("\u{1b}[?25h")
        
        write(STDOUT_FILENO, ab.buffer, ab.length)
    }
    
    private func readKey() -> Key {
        
        var c: char = 0x00
        var nread: Int
        
        repeat {
            
            nread = read(STDIN_FILENO, &c, 1)
            
            if nread == -1 && errno != EAGAIN {
                Terminal.die(description: "read")
            }
            
        } while nread != 1
        
        if c == "\u{1b}".char {
            
            var seq: [char] = Array(repeating: 0x00, count: 3)
            
            guard read(STDIN_FILENO, &seq[0], 1) == 1,
                  read(STDIN_FILENO, &seq[1], 1) == 1
                else { return .init(type: .escape) }
            
            if seq[0] == "[".char {
                
                if seq[1] >= "0".char! && seq[1] <= "9".char! {
                    
                    guard read(STDIN_FILENO, &seq[2], 1) == 1
                        else { return .init(type: .escape) }
                    
                    if seq[2] == "~".char! {
                        
                        switch seq[1] {
                        case "1".char:
                            return .init(type: .home)
                        case "3".char:
                            return .init(type: .delete)
                        case "4".char:
                            return .init(type: .end)
                        case "5".char:
                            return .init(type: .pageUp)
                        case "6".char:
                            return .init(type: .pageDown)
                        case "7".char:
                            return .init(type: .home)
                        case "8".char:
                            return .init(type: .end)
                        default: break
                        }
                    }
                } else {
                
                    switch seq[1] {
                    case "A".char:
                        return .init(type: .arrowUp)
                    case "B".char:
                        return .init(type: .arrowDown)
                    case "C".char:
                        return .init(type: .arrowRight)
                    case "D".char:
                        return .init(type: .arrowLeft)
                    case "H".char:
                        return .init(type: .home)
                    case "F".char:
                        return .init(type: .end)
                    default: break
                    }
                }
            } else if (seq[0] == "0".char!) {
                
                switch seq[1] {
                case "H".char:
                    return .init(type: .home)
                case "F".char:
                    return .init(type: .end)
                default: break
                }
            }
            return .init(type: .escape)
        } else {
            return .init(type: .alphabet(c))
        }
    }
    
    private func CTRL_KEY(_ str: String) -> char {
        
        guard str.count == 1 else { return 0x00 }
        
        let c = Character(str)
        
        return (c.asciiValue ?? 0x00) & 0x1f
    }
}
