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
    case Token = "token"
    case Code = "code"
}

struct OAuthState {
    let clientId: String
    let clientSecret: String
    let redirectUri: String
    let responseType: OAuthResponseType
}

struct AuthenticationResult {
    let responseType: OAuthResponseType
    let value: String
}

class SoundCloudAuthenticator {
    let authenticationURLString = "https://soundcloud.com/connect"
    let oauthState: OAuthState
    
    // MARK: - Init
    
    required init(oauthState: OAuthState) {
        self.oauthState = oauthState;
    }
    
    // MARK: - Public
    
    func buildLoginURL() -> NSURL {
        let urlComponents = NSURLComponents(string: authenticationURLString)!
        urlComponents.queryItems = loginParameters()
        return urlComponents.URL!
    }
    
    func resultFromAuthenticationResponse(url: NSURL) -> AuthenticationResult? {
        if !isRedirectToApp(url) {
            return nil
        }
        
        switch self.oauthState.responseType {
        case OAuthResponseType.Token: return retrieveToken(url)
        case OAuthResponseType.Code: return retrieveCode(url)
        }
    }
    
    func isOAuthResponse(url: NSURL) -> Bool {
        return isRedirectToApp(url)
    }
    
    // MARK: - Private
    
    private func loginParameters() -> [NSURLQueryItem] {
        let parameters = [
            "client_id"     : self.oauthState.clientId,
            "client_secret" : self.oauthState.clientSecret,
            "response_type" : self.oauthState.responseType.rawValue,
            "redirect_uri"  : self.oauthState.redirectUri,
            "scope"         : "non-expiring",
            "display"       : "popup" ]
        
        var queryItems = [NSURLQueryItem]()
        for (name, value) in parameters {
            queryItems.append(NSURLQueryItem(name: name, value: value))
        }
        return queryItems
    }
    
    private func isRedirectToApp(url: NSURL) -> Bool {
        let ourScheme = NSURL(string: self.oauthState.redirectUri)?.scheme,
        redirectScheme = url.scheme
        
        return ourScheme == redirectScheme
    }
    
    private func retrieveToken(url: NSURL) -> AuthenticationResult? {
        // Expected URL is:
        // scsample://oauth?#access_token=1-91457-152254708-04e9df008828ee&expires_in=21599&scope=%2A
        if let fragment = url.fragment,
            accessToken = parameterValue("access_token", fragment: fragment) {
                return AuthenticationResult(responseType: OAuthResponseType.Token, value: accessToken)
        } else {
            return nil
        }
    }
    
    private func retrieveCode(url: NSURL) -> AuthenticationResult? {
        // Expected URL is:
        // scsample://oauth?code=e99fa100e527ff5ae932b54c004ba476#
        if let fragment = url.query, code = parameterValue("code", fragment: fragment) {
            return AuthenticationResult(responseType: OAuthResponseType.Code, value: code)
        } else {
            return nil
        }
    }
    
    private func parameterValue(name: String, fragment: String) -> String? {
        
        let pairs = fragment.componentsSeparatedByString("&")
        for pair in pairs {
            let components = pair.componentsSeparatedByString("=")
            if components.first == AccessTokenKey {
                return components.last
            }
        }
        
        return nil
    }
}