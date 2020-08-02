import UIKit
import Swifter
import SafariServices

class ViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var tweetMsgArea: UITextView!
    private let appStatus = AppStatus()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tweetPushed(_ sender: Any) {
        tweet()
    }

    func tweet() {
        let TWITTER_CONSUMER_KEY = "{Consumer API key}"
        let TWITTER_CONSUMER_SECRET = "{Consumer API secret key}"

        // load from UserDefaults
        let tokenKey = self.appStatus.twitterTokenKey
        let tokenSecret = self.appStatus.twitterTokenSecret

        if tokenKey == nil || tokenSecret == nil {
            let swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)

            swifter.authorize(
                withCallback: URL(string: "swifter-{Consumer API key}://")!,
                presentingFrom: self,
                success: { accessToken, response in
                    print(response)
                    guard let accessToken = accessToken else { return }
                    self.appStatus.twitterTokenKey = accessToken.key
                    self.appStatus.twitterTokenSecret = accessToken.secret
                    self.tweet()
            }, failure: { error in
                print(error)
            })

        } else {
            let swifter = Swifter(consumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET, oauthToken: tokenKey!, oauthTokenSecret: tokenSecret!)

            swifter.postTweet(status: tweetMsgArea.text, success: { response in
                print(response)
            }, failure: { error in
                print(error)
            })
        }
    }
}

class AppStatus {
    var userdefault = UserDefaults.init(suiteName: "app_status")!

    var twitterTokenKey : String? {
        get {
            if let token : String = userdefault["token_key"] {
                return token
            } else {
                return nil
            }
        }

        set {
            userdefault["token_key"] = newValue
        }
    }

    var twitterTokenSecret : String? {
        get {
            if let secret : String = userdefault["token_secret"] {
                return secret
            } else {
                return nil
            }
        }

        set {
            userdefault["token_secret"] = newValue
        }
    }
}

extension UserDefaults {
    subscript<T: Any>(key: String) -> T? {
        get {
            if let value = object(forKey: key) {
                return value as? T
            } else {
                return nil
            }
        }
        set(_newValue) {
            if let newValue = _newValue {
                set(newValue, forKey: key)
            } else {
                removeObject(forKey: key)
            }
            synchronize()
        }
    }
}
