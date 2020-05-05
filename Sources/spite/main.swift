import Foundation

func die(description: String) {
    
    perror(description)
    exit(1)
}

func main() -> Int {

    let stdio = FileHandle.standardInput
    let terminal = Terminal()
    
    print("Hello.")
    
    terminal.enter(mode: .raw)
    
    while true {
        
        var c: UInt8 = 0
        
        if read(stdio.fileDescriptor, &c, 1) == -1 && errno != EAGAIN {
            die(description: "read")
        }
        
        if iscntrl(Int32(c)) > 0 {
            print(String(format: "%d\r", c))
        } else {
            print(String(format: "%d ('%c')\r", c, c))
        }
        
        if c.equals(to: Character("q")) {
            break
        }
    }
    
    print("Bye!")

    return 0
}

_ = main()
