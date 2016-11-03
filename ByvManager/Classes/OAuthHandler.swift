//
//  OAuth2Handler.swift
//  Pods
//
//  Created by Adrian Apodaca on 25/10/16.
//
//

import Foundation
import Alamofire

public class OAuthHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var clientID: String
    private var clientSecret: String
    private var baseURLString: String
    private var accessToken: String?
    private var refreshToken: String?
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init() {
        self.clientID = Configuration.auth("byv_client_id") as! String
        self.clientSecret = Configuration.auth("byv_client_secret") as! String
        self.baseURLString = Environment.baseUrl()
        if let cred = Credentials.current() {
            self.accessToken = cred.access_token
            self.refreshToken = cred.refresh_token
        }
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let token = self.accessToken, let url = urlRequest.url, url.absoluteString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        if let url = urlRequest.url, url.absoluteString.hasPrefix(baseURLString) {
            
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            print("CADUCADO!!!!!")
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { print("intento de refresh"); return }
        
        if let rt: String = refreshToken {
            
            isRefreshing = true
            
            let urlString = "\(Environment.baseUrl())/\(url_token())"
            
            let parameters: [String: Any] = [
                "refresh_token": rt,
                "client_id": clientID,
                "client_secret": clientSecret,
                "grant_type": "refresh_token"
            ]
            
            print(parameters)
            sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseJSON { [weak self] response in
                    guard let strongSelf = self else { print("strongSelf"); return }
                    print("refreshing!!!")
                    if let response = response.response!.statusCode as? HTTPURLResponse, response.statusCode == 401 {
                        //Refresh token invalid
                        Credentials.removeCredentials()
                        completion(false, nil, nil)
                    } else {
                        if let cred = Credentials.store(response.data) {
                            completion(true, cred.access_token, cred.refresh_token)
                        } else {
                            completion(false, nil, nil)
                        }
                    }
                    
                    strongSelf.isRefreshing = false
            }
        } else {
            Credentials.removeCredentials()
            completion(false, nil, nil)
        }
    }
}
