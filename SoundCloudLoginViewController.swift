//
//  SoundCloudLoginViewController.swift
//
//
//  Created on 23.02.16.
//  Copyright © 2016 steelkiwi. All rights reserved.
//

import UIKit

protocol SoundCloudLoginResultsDelegate: class {
    func didSucceed(loginViewController: SoundCloudLoginViewController, authResult: AuthenticationResult)
    func didFail(loginViewController: SoundCloudLoginViewController, error: NSError?)
}

class SoundCloudLoginViewController: UIViewController {
    
    private var authenticator: SoundCloudAuthenticator?
    weak var delegate: SoundCloudLoginResultsDelegate?
    
    @IBOutlet private weak var webView: UIWebView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticator = SoundCloudAuthenticator(oauthState: OAuthState(
            clientId: SoundCloudClientID,
            clientSecret: SoundCloudClientSecret,
            redirectUri: SoundCloudRedirectURI,
            responseType: OAuthResponseType.Token))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startAuthorization()
    }
    
    // MARK: - Private
    
    private func startAuthorization() {
        if let authenticator = self.authenticator,
            webView = self.webView {
                let url = authenticator.buildLoginURL()
                webView.loadRequest(NSURLRequest(URL: url))
        }
    }
}

// MARK: - UIWebViewDelegate

extension SoundCloudLoginViewController : UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!
        if let authenticator = self.authenticator where authenticator.isOAuthResponse(url) {
            dismissViewControllerAnimated(true, completion: {
                if let authResult = authenticator.resultFromAuthenticationResponse(url), delegate = self.delegate {
                    delegate.didSucceed(self, authResult: authResult)
                } else if let delegate = self.delegate {
                    delegate.didFail(self, error: nil)
                }
            })
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loader.hidden = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        // UI interrupt
        if error?.code != 102 {
            delegate?.didFail(self, error: error)
        }
    }
    
}