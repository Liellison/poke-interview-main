//
//  onTopPokeTests.swift
//  onTopPokeTests
//
//  Created by Liellison Menezes on 04/02/25.
//

import XCTest
@testable import onTopPoke

class onTopPokeTests: XCTestCase {
    var sut: APIClient!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        session = URLSession(configuration: configuration)
        sut = APIClient(session: session)
    }
    
    override func tearDown() {
        sut = nil
        session = nil
        URLProtocolStub.stubData = nil
        URLProtocolStub.stubError = nil
        URLProtocolStub.requestObserver = nil
        super.tearDown()
    }
    
    /// Tests the success scenario, where the JSON is valid and the model is decoded correctly.
    func testFetchPokemon_SuccessfulResponse() {
        let jsonString = """
        {
            "id": 1,
            "name": "Bulbasaur",
            "evolutionChain": [2, 3]
        }
        """
        let data = jsonString.data(using: .utf8)
        URLProtocolStub.stubData = data
        
        let expectation = self.expectation(description: "Fetch Pokemon")
        
        sut.fetchPokemon { result in
            switch result {
            case .success(let pokemon):
                XCTAssertEqual(pokemon.id, 1)
                XCTAssertEqual(pokemon.name, "Bulbasaur")
                XCTAssertEqual(pokemon.evolutionChain, [2, 3])
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    /// Tests the scenario where the received JSON is invalid for the expected model.
    func testFetchPokemon_InvalidJSON() {
        let invalidJSONString = """
        {
            "identifier": "invalid"
        }
        """
        let data = invalidJSONString.data(using: .utf8)
        URLProtocolStub.stubData = data
        
        let expectation = self.expectation(description: "Fetch Pokemon with invalid JSON")
        
        sut.fetchPokemon { result in
            switch result {
            case .success:
                XCTFail("Expected failure due to invalid JSON, but succeeded.")
            case .failure(let error):
                switch error {
                case .decodingError:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Expected a decoding error but got: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    /// Tests the scenario where a network error occurs (simulated).
    func testFetchPokemon_NetworkError() {
        let expectedError = NSError(domain: "NetworkError", code: -1, userInfo: nil)
        URLProtocolStub.stubError = expectedError
        
        let expectation = self.expectation(description: "Fetch Pokemon with network error")
        
        sut.fetchPokemon { result in
            switch result {
            case .success:
                XCTFail("Expected network error but got success.")
            case .failure(let error):
                switch error {
                case .networkError(let error as NSError):
                    XCTAssertEqual(error.domain, expectedError.domain)
                    XCTAssertEqual(error.code, expectedError.code)
                default:
                    XCTFail("Expected a network error but got it: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
}

