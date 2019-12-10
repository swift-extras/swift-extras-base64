import Foundation
import XCTest
@testable import Base64

class IntegrationTests: XCTestCase {
  
  func testEncodeAndDecodingĨ() throws {
    
    var input = "Ĩ"
    let output = try input.withUTF8 { (ptr) -> String in
      let bytes   = String(base64Encoding: ptr)
      let decoded = try bytes.base64decoded()
      
      return String(bytes: decoded, encoding: .utf8)!
    }
    
    XCTAssertEqual(input, output)
  }
  
}
