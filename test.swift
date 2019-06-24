import Foundation
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

class FileSystem {

    public func resolveSymlinks(_ pathStr: String) -> String {
        // FIXME: We can't use FileManager's destinationOfSymbolicLink because
        // that implements readlink and not realpath.
        if let resultPtr = realpath(pathStr, nil) {
            let result = String(cString: resultPtr)
            // FIXME: We should measure if it's really more efficient to compare the strings first.
            return result
        }
        return pathStr
    }

    func isExecutableFile(_ path: String) -> Bool {
        // Our semantics doesn't consider directories.
        return  (self.isFile(path) || self.isSymlink(path)) && FileManager.default.isExecutableFile(atPath: path)
    }

    func exists(_ path: String, followSymlink: Bool) -> Bool {
        if followSymlink {
            return FileManager.default.fileExists(atPath: path)
        }
        return (try? FileManager.default.attributesOfItem(atPath: path)) != nil
    }

    func isDirectory(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists: Bool = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func isFile(_ path: String) -> Bool {
        let path = resolveSymlinks(path)
        let attrs = try? FileManager.default.attributesOfItem(atPath: path)
        return attrs?[.type] as? FileAttributeType == .typeRegular
    }

    func isSymlink(_ path: String) -> Bool {
        let attrs = try? FileManager.default.attributesOfItem(atPath: path)
        return attrs?[.type] as? FileAttributeType == .typeSymbolicLink
    }

    func getFileInfo(_ path: String) throws -> [FileAttributeKey: Any] {
        let attrs = try FileManager.default.attributesOfItem(atPath: path)
        return attrs
    }

    var currentWorkingDirectory: String {
        let cwdStr = FileManager.default.currentDirectoryPath
        return cwdStr
    }
}

let fs = FileSystem()

var path = "/bin/ls"
print("\(path): isExecutable=\(fs.isExecutableFile(path)), isFile=\(fs.isFile(path)), isSymlink=\(fs.isSymlink(path)), exists=\(fs.exists(path, followSymlink: true))")

path = "/tmp/swift-5.1-DEVELOPMENT-SNAPSHOT-2019-06-16-a-ubuntu18.04/usr/bin/swift"
print("\(path): isExecutable=\(fs.isExecutableFile(path)), isFile=\(fs.isFile(path)), isSymlink=\(fs.isSymlink(path)), exists=\(fs.exists(path, followSymlink: true))")

path = "/tmp/swift-5.1-DEVELOPMENT-SNAPSHOT-2019-06-16-a-ubuntu18.04/usr/bin/swiftc"
print("\(path): isExecutable=\(fs.isExecutableFile(path)), isFile=\(fs.isFile(path)), isSymlink=\(fs.isSymlink(path)), exists=\(fs.exists(path, followSymlink: true))")

