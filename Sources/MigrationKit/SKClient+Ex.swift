import SKClient
import SourceKittenFramework

extension SKClient {
    @discardableResult
    public func demangling(_ names: [String]) throws -> SourceKitResponse {
      let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: [
        "key.request": UID("source.request.demangle"),
        "key.names": names,
      ]).send()
      return SourceKitResponse(raw)
    }
    
    @discardableResult
    public func find(usr: String) throws -> SourceKitResponse {
      let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: [
        "key.request": UID("source.request.editor.find_usr"),
        "key.usr": usr,
        "key.sourcefile": path,
        "key.compilerargs": arguments,
      ]).send()
      return SourceKitResponse(raw)
    }
}
