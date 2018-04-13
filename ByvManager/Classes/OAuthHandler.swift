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
        self.reloadCredentials()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reloadCredentials),
                                               name: ByvNotifications.credUpdated,
                                               object: nil)
    }
    
    @objc private func reloadCredentials() {
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
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            if ByvManager.debugMode {
                print("CADUCADO!!!!!")
            }
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach {
                        $0(succeeded, 0.0)
                    }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { if ByvManager.debugMode {print("intento de refresh")}; return }
        
        if let refreshToken: String = refreshToken, let accessToken: String = accessToken {
            
            isRefreshing = true
            
            let urlString = "\(Environment.baseUrl())/\(url_token())/refresh"
            
            let parameters: [String: Any] = [
                "refreshToken": refreshToken,
                "client_id": clientID,
                "client_secret": clientSecret,
                "accessToken": accessToken,
                "grant_type": "refresh"
            ]
            
            if ByvManager.debugMode {
                print(parameters)
            }
            var headers: HTTPHeaders? = nil
            if let dId = Device().deviceId {
                headers = ["DeviceId": "\(dId)"]
            }
            sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success:
                        if let cred = Credentials.store(response.data) {
                            completion(true, cred.access_token, cred.refresh_token)
                        } else {
                            completion(false, nil, nil)
                        }
                    case .failure(let error):
                        print(error)
                        if ByvManager.debugMode {
                            print("REQUEST REFERSH:\nParams:")
                            dump(parameters)
                            debugPrint(response)
                            print("Data: \(String(describing: String(data: response.data!, encoding: .utf8)))")
                        }
                        if response.response?.statusCode == 401 {
                            //Refresh token invalid
                            ByvAuth.logout()
                            completion(false, nil, nil)
                        }
                    }
                    self.isRefreshing = false
            }
        } else {
            ByvAuth.logout()
            completion(false, nil, nil)
        }
    }
}
