//
//  ShadowsocksURIParserTests.swift
//  ShadowsocksClientTests
//
//  Created by Anton Priakhin on 01.09.2023.
//

import XCTest
@testable import ShadowsocksClient

final class ShadowsocksURIParserTests: XCTestCase {
    var parser: ShadowsocksURIParsing!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        parser = ShadowsocksURIParser()
    }

    override func tearDownWithError() throws {
        parser = nil
        
        try super.tearDownWithError()
    }
    
    func testParse() throws {
        // given
        let uri1 = "ss://YWVzLTEyOC1nY206cGFzc3dvcmQ%3D@192.168.100.1:8888#Tag%201"
        let uri2 = "ss://c2Fsc2EyMDp0ZXN0QDE5Mi4xNjguMTAwLjE6ODg4OA==#Tag%201"
        let uri3 = "ss://c2Fsc2EyMDp0ZXN0QDE5Mi4xNjguMTAwLjE6ODg4OA"
        
        // when
        let result1 = parser.parse(uri: uri1)
        let result2 = parser.parse(uri: uri2)
        let result3 = parser.parse(uri: uri3)
        
        // then
        XCTAssertEqual(result1?.host, "192.168.100.1")
        XCTAssertEqual(result1?.port, 8888)
        XCTAssertEqual(result1?.method, ShadowsocksMethod.aes128Gcm)
        XCTAssertEqual(result1?.password, "password")
        XCTAssertEqual(result1?.tag, "Tag 1")
        XCTAssertEqual(result1?.extra, [:])
        
        XCTAssertEqual(result2?.host, "192.168.100.1")
        XCTAssertEqual(result2?.port, 8888)
        XCTAssertEqual(result2?.method, ShadowsocksMethod.salsa20)
        XCTAssertEqual(result2?.password, "test")
        XCTAssertEqual(result2?.tag, "Tag 1")
        XCTAssertEqual(result2?.extra, [:])
        
        XCTAssertNil(result3)
    }

    func testParseLegacyBase64URI() throws {
        // given
        let uri1 = "ss://c2Fsc2EyMDp0ZXN0QDE5Mi4xNjguMTAwLjE6ODg4OA=="
        let uri2 = "ss://c2Fsc2EyMDp0ZXN0QDE5Mi4xNjguMTAwLjE6ODg4OA==#Tag%201"
        let uri3 = "ss://c2Fsc2EyMDp0ZXN0QDE5Mi4xNjguMTAwLjE6ODg4OA"
        
        // when
        let result1 = parser.parseLegacyBase64URI(uri: uri1)
        let result2 = parser.parseLegacyBase64URI(uri: uri2)
        let result3 = parser.parseLegacyBase64URI(uri: uri3)

        // then
        XCTAssertEqual(result1?.host, "192.168.100.1")
        XCTAssertEqual(result1?.port, 8888)
        XCTAssertEqual(result1?.method, ShadowsocksMethod.salsa20)
        XCTAssertEqual(result1?.password, "test")
        XCTAssertEqual(result1?.tag, nil)
        XCTAssertEqual(result1?.extra, [:])
        
        XCTAssertEqual(result2?.host, "192.168.100.1")
        XCTAssertEqual(result2?.port, 8888)
        XCTAssertEqual(result2?.method, ShadowsocksMethod.salsa20)
        XCTAssertEqual(result2?.password, "test")
        XCTAssertEqual(result2?.tag, "Tag 1")
        XCTAssertEqual(result2?.extra, [:])
        
        XCTAssertNil(result3)
    }
    
    func testParseSIP002URI() {
        // given
        let uri1 = "ss://YWVzLTEyOC1nY206cGFzc3dvcmQ%3D@192.168.100.1:8888"
        let uri2 = "ss://YWVzLTEyOC1nY206cGFzc3dvcmQ%3D@192.168.100.1:8888#Tag%201"
        let uri3 = "ss://Y2FtZWxsaWEtMTI4LWNmYjp0ZXN0@192.168.100.1:8888/?plugin=obfs-local%3Bobfs%3Dhttp"
        let uri4 = "ss://Y2FtZWxsaWEtMTI4LWNmYjp0ZXN0@192.168.100.1:8888/?plugin=obfs-local%3Bobfs%3Dhttp#Example2"
        let uri5 = "ss://YWVzLTEyOC1nY206cGFzc3dvcmQ@192.168.100.1:8888"

        // when
        let result1 = parser.parseSIP002URI(uri: uri1)
        let result2 = parser.parseSIP002URI(uri: uri2)
        let result3 = parser.parseSIP002URI(uri: uri3)
        let result4 = parser.parseSIP002URI(uri: uri4)
        let result5 = parser.parseSIP002URI(uri: uri5)
        
        // then
        XCTAssertEqual(result1?.host, "192.168.100.1")
        XCTAssertEqual(result1?.port, 8888)
        XCTAssertEqual(result1?.method, ShadowsocksMethod.aes128Gcm)
        XCTAssertEqual(result1?.password, "password")
        XCTAssertEqual(result1?.tag, nil)
        XCTAssertEqual(result1?.extra, [:])
        
        XCTAssertEqual(result2?.host, "192.168.100.1")
        XCTAssertEqual(result2?.port, 8888)
        XCTAssertEqual(result2?.method, ShadowsocksMethod.aes128Gcm)
        XCTAssertEqual(result2?.password, "password")
        XCTAssertEqual(result2?.tag, "Tag 1")
        XCTAssertEqual(result2?.extra, [:])
        
        XCTAssertEqual(result3?.host, "192.168.100.1")
        XCTAssertEqual(result3?.port, 8888)
        XCTAssertEqual(result3?.method, ShadowsocksMethod.camellia128Cfb)
        XCTAssertEqual(result3?.password, "test")
        XCTAssertEqual(result3?.tag, nil)
        XCTAssertEqual(result3?.extra, ["plugin": "obfs-local;obfs=http"])
        
        XCTAssertEqual(result4?.host, "192.168.100.1")
        XCTAssertEqual(result4?.port, 8888)
        XCTAssertEqual(result4?.method, ShadowsocksMethod.camellia128Cfb)
        XCTAssertEqual(result4?.password, "test")
        XCTAssertEqual(result4?.tag, "Example2")
        XCTAssertEqual(result4?.extra, ["plugin": "obfs-local;obfs=http"])

        XCTAssertNil(result5)
    }
}
