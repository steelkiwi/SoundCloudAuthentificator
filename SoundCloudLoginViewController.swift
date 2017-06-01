//
//  SoundCloudLoginViewController.swift
//
//
//  Created on 23.02.16.
//  Copyright © 2016 steelkiwi. All rights reserved.
//

import UIKit

protocol SoundCloudLoginResultsDelegate: class {
    func didSucceed(loginVC: SoundCloudLoginViewController, authResult: AuthenticationResult)
    func didFail(loginVC: SoundCloudLoginViewController, error: Error?)
}

class SoundCloudLoginViewController: UIViewController {
    
    fileprivate var authenticator   : SoundCloudAuthenticator?
    public weak var delegate        : SoundCloudLoginResultsDelegate?
    
    @IBOutlet fileprivate weak var webView  : UIWebView!
    @IBOutlet fileprivate weak var loader   : UIActivityIndicatorView!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticator = SoundCloudAuthenticator(oauthState: OAuthState(
            clientId: "",       //SoundCloud ClientID,
            clientSecret: "",   //SoundCloud ClientSecret,
            redirectUri: "",    //SoundCloud RedirectURI,
            responseType: .token))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startAuthorization()
    }
    
    // MARK: - Private
    
    private func startAuthorization() {
        if let authenticator = self.authenticator,
            let webView = self.webView {
            let url = authenticator.buildLoginURL()
            webView.loadRequest(URLRequest(url: url))
        }
    }
}

// MARK: - UIWebViewDelegate

extension SoundCloudLoginViewController : UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        
        if let authenticator = self.authenticator,
            authenticator.isOAuthResponse(url: url) {
            
            dismiss(animated: true, completion: {
                if let authResult = authenticator.resultFromAuthenticationResponse(url: url),
                    let delegate = self.delegate {
                    delegate.didSucceed(loginVC: self, authResult: authResult)
                } else if let delegate = self.delegate {
                    delegate.didFail(loginVC: self, error: nil)
                }
            })
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loader.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        // UI interrupt
        if (error as NSError).code != 102 {
            self.delegate?.didFail(loginVC: self, error: error)
        }
    }
    
}
