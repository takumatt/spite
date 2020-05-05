import Foundation

func main() -> Int {

    let stdio = FileHandle.standardInput
    var char: UInt8 = 0
    let terminal = Terminal()
    
    print("Hello.")
    
    terminal.enter(mode: .raw)

    while read(stdio.fileDescriptor, &char, 1) == 1
        && !char.equals(to: Character("q")) {
            
            if iscntrl(Int32(char)) > 0 {
                print(String(format: "%d\r", char))
            } else {
                print(String(format: "%d ('%c')\r", char, char))
            }
    }
    
    print("Bye!")

    return 0
}

_ = main()
