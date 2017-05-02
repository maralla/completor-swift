import Foundation
import SourceKittenFramework

var spmModule = ""
var compilerArgs = ""

var iter = CommandLine.arguments[1 ..< CommandLine.arguments.endIndex].makeIterator()
while let option = iter.next() {
    guard let value = iter.next() else {
        print("Invalid argument")
        exit(EXIT_FAILURE)
    }

    switch option {
    case "-spm-module": spmModule = value
    case "-compiler-args": compilerArgs = value
    default:
        print("Invalid argument: \(option)")
        exit(EXIT_FAILURE)
    }
}

let path = "\(NSUUID().uuidString).swift"
var args: [String]

if spmModule.isEmpty {
    args = ["-c", path] + compilerArgs.characters.split(separator: " ").map(String.init)
    if args.index(of: "-sdk") == nil {
        args.append(contentsOf: ["-sdk", sdkPath()])
    }
} else {
    guard let module = Module(spmName: spmModule) else {
        print("Bad module name: \(spmModule)")
        exit(EXIT_FAILURE)
    }
    args = module.compilerArguments
}

func parseInput(_ input: String) -> (String, Int64)? {
    guard let data = input.data(using: String.Encoding.utf8) else {
        return nil
    }

    do {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
            return nil
        }
        guard let content = json["content"] as? String else {
            return nil
        }
        guard let offset = json["offset"] as? Int64 else {
            return nil
        }
        return (content, offset)
    } catch {
        return nil
    }
}

func toJson(_ obj: Any) -> Data {
    do {
        return try JSONSerialization.data(withJSONObject: obj, options: [])
    } catch {}
    return Data()
}

while true {
    guard let input = readLine(strippingNewline: true) else {
        continue
    }
    guard let (content, offset) = parseInput(input) else {
        continue
    }
    let request = Request.codeCompletionRequest(file: path, contents: content, offset: offset, arguments: args)
    let items = CodeCompletionItem.parse(response: request.send()).map {
        ["abbr": $0.descriptionKey, "menu": $0.kind, "word": $0.sourcetext]
    }
    var data = toJson(items)
    data.append(10)
    FileHandle.standardOutput.write(data)
}
