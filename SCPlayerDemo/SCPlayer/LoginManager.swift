//
//  LoginManager.swift
//  SCPlayer
//
//  Created by Viktor Olesenko on 06.06.17.
//  Copyright © 2017 Viktor Olesenko. All rights reserved.
//

import UIKit

typealias SCLoginSuccessBlock = (_ soundcloudToken: String, _ soundcloudId: String) -> Void
typealias SCLoginFailureBlock = (_ error: Error?) -> Void

class LoginManager: NSObject, SoundCloudLoginResultsDelegate {
    
    var loginSuccessBlock: SCLoginSuccessBlock?
    var loginFailureBlock: SCLoginFailureBlock?
    
    func getSoundcloudToken(fromController controller: UIViewController, success: @escaping SCLoginSuccessBlock, failure: @escaping SCLoginFailureBlock) {
        
        loginSuccessBlock = success
        loginFailureBlock = failure
        
        let soundCloudLoginController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: String(describing: SoundCloudLoginViewController.self)) as! SoundCloudLoginViewController
        soundCloudLoginController.delegate = self
        controller.navigationController?.present(soundCloudLoginController, animated: true, completion: nil)
    }
    
    func didSucceed(loginVC: SoundCloudLoginViewController, authResult: AuthenticationResult) {
        let meUrl = "https://api.soundcloud.com/me?oauth_token=" + authResult.value
        
        URLSession.shared.dataTask(with: URL(string: meUrl)!, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                self.loginFailureBlock?(error!)
                self.reset()
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String, Any>,
                let id = json?["id"] as? Int {
                self.loginSuccessBlock?(authResult.value, String(id))
                self.reset()
            } else {
                self.loginFailureBlock!(nil) // Failed to connect SoundCloud
                self.reset()
            }
            
        }).resume()
    }
    
    func didFail(loginVC: SoundCloudLoginViewController, error: Error?) {
        loginFailureBlock?(error)
        reset()
    }
    
    private func reset() {
        loginSuccessBlock = nil
        loginFailureBlock = nil
    }
    
}
