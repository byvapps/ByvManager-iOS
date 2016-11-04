//
//  Urls.swift
//  Pods
//
//  Created by Adrian Apodaca on 26/10/16.
//
//

import Foundation

// MARK: - Paths

public func url_devices() -> String {
    if let path = Configuration.override("DEVICES_URL") as? String {
        return path
    } else {
        return "devices/api"
    }
}

public func url_token() -> String {
    if let path = Configuration.override("TOKEN_URL") as? String {
        return path
    } else {
        return "auth/token"
    }
}

public func url_request_magic() -> String {
    if let path = Configuration.override("TOKEN_URL") as? String {
        return path
    } else {
        return "auth-password/api/magic"
    }
}

public func url_request_magic_callback() -> String {
    if let path = Configuration.override("TOKEN_URL") as? String {
        return path
    } else {
        return "auth-password/magic/callback"
    }
}

public func url_request_reset_password() -> String {
    if let path = Configuration.override("TOKEN_URL") as? String {
        return path
    } else {
        return "auth-password/api/reset"
    }
}

public func url_request_reset_password_callback() -> String {
    if let path = Configuration.override("TOKEN_URL") as? String {
        return path
    } else {
        return "auth-password/reset/callback"
    }
}
        
///auth-password/reset/callback

public func url_token_social() -> String {
    if let path = Configuration.override("SOCIAL_TOKEN_URL") as? String {
        return path as! String
    } else {
        return "auth/token/social"
    }
}

public func url_facebook_login() -> String {
    if let path = Configuration.override("FACBEBOOK_LOGIN_URL") as? String {
        return path
    } else {
        return "auth/facebook"
    }
}

public func url_twitter_login() -> String {
    if let path = Configuration.override("TWITTER_LOGIN_URL") as? String {
        return path
    } else {
        return "auth/twitter"
    }
}

public func url_linkedin_login() -> String {
    if let path = Configuration.override("LINKEDIN_LOGIN_URL") as? String {
        return path
    } else {
        return "auth/linkedin"
    }
}

public func url_google_login() -> String {
    if let path = Configuration.override("GOOGLE_LOGIN_URL") as? String {
        return path
    } else {
        return "auth/google"
    }
}

public func url_social_callback() -> String {
    if let path = Configuration.override("SOCIAL_CALLBACK_URL") as? String {
        return path
    } else {
        return "callback"
    }
}

public func url_logout() -> String {
    if let path = Configuration.override("LOGOUT_URL") as? String {
        return path
    } else {
        return "auth/logout"
    }
}

public func url_profile() -> String {
    if let path = Configuration.override("PROFILE_URL") as? String {
        return path
    } else {
        return "api/profile"
    }
}
