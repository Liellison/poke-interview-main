//
//  URLProtocolStub.swift
//  onTopPokeTests
//
//  Created by Liellison Menezes on 04/02/25.
//

import Foundation

class URLProtocolStub: URLProtocol {
    static var stubData: Data?
    static var stubError: Error?
    static var requestObserver: ((URLRequest) -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let observer = URLProtocolStub.requestObserver {
            observer(request)
        }
        if let error = URLProtocolStub.stubError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let data = URLProtocolStub.stubData {
                self.client?.urlProtocol(self, didLoad: data)
            }
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

