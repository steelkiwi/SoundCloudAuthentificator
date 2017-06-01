//
//  SoundCloudAuthenticator.swift
//
//
//  Created on 23.02.16.
//  Copyright © 2016 SoundCloud. All rights reserved.
//  Source - https://github.com/soundcloud/iOSOAuthDemo/blob/master/SoundCloudDemo/SoundCloudAuthenticator.swift
//

import Foundation

enum OAuthResponseType: String {
    case token
    case code
}

struct OAuthState {
    let clientId        : String
    let clientSecret    : String
    let redirectUri     : String
    let responseType    : OAuthResponseType
}

struct AuthenticationResult {
    let responseType    : OAuthResponseType
    let value           : String
}

class SoundCloudAuthenticator {
    let authenticationURLString = "https://soundcloud.com/connect"
    let oauthState: OAuthState
    
    // MARK: - Init
    
    required init(oauthState: OAuthState) {
        self.oauthState = oauthState;
    }
    
    // MARK: - Public
    
    func buildLoginURL() -> URL {
        var urlComponents = URLComponents(string: authenticationURLString)!
        urlComponents.queryItems = loginParameters()
        return urlComponents.url!
    }
    
    func resultFromAuthenticationResponse(url: URL) -> AuthenticationResult? {
        if !isRedirectToApp(url: url) {
            return nil
        }
        
        switch self.oauthState.responseType {
        case OAuthResponseType.token: return retrieveToken(url: url)
        case OAuthResponseType.code:  return retrieveCode(url: url)
        }
    }
    
    func isOAuthResponse(url: URL) -> Bool {
        return isRedirectToApp(url: url)
    }
    
    // MARK: - Private
    
    private func loginParameters() -> [URLQueryItem] {
        let parameters = [
            "client_id"     : oauthState.clientId,
            "client_secret" : oauthState.clientSecret,
            "response_type" : oauthState.responseType.rawValue,
            "redirect_uri"  : oauthState.redirectUri,
            "scope"         : "non-expiring",
            "display"       : "popup" ]
        
        var queryItems = [URLQueryItem]()
        for (name, value) in parameters {
            queryItems.append(URLQueryItem(name: name, value: value))
        }
        return queryItems
    }
    
    private func isRedirectToApp(url: URL) -> Bool {
        let ourScheme = URL(string: self.oauthState.redirectUri)?.scheme
        let redirectScheme = url.scheme
        
        return ourScheme == redirectScheme
    }
    
    private func retrieveToken(url: URL) -> AuthenticationResult? {
        // Expected URL is:
        // scsample://oauth?#access_token=1-91457-152254718-04e9df008828ee&expires_in=21599&scope=%2A
        guard let fragment = url.fragment,
            let accessToken = parameterValue(name: "access_token", fragment: fragment) else {
                return nil
        }
        
        return AuthenticationResult(responseType: .token, value: accessToken)
    }
    
    private func retrieveCode(url: URL) -> AuthenticationResult? {
        // Expected URL is:
        // scsample://oauth?code=e99fa100e527fl5ae932b54c004ba476#
        guard let fragment = url.query,
            let code = parameterValue(name: "code", fragment: fragment) else {
                return nil
        }
        
        return AuthenticationResult(responseType: .code, value: code)
    }
    
    private func parameterValue(name: String, fragment: String) -> String? {
        
        let pairs = fragment.components(separatedBy: "&")
        for pair in pairs {
            let components = pair.components(separatedBy: "=")
            if components.first == "access_token" {
                return components.last
            }
        }
        
        return nil
    }
}
