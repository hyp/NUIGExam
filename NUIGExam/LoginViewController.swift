import UIKit
import Foundation

// Controls the login and timetable fetching process.
class LoginViewController: UIViewController {
    
    @IBOutlet weak var studentNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    var dataProvider: NUIGWebsiteExamDataProvider? = nil
    
    func error(msg: String) {
        let alertView = UIAlertView()
        alertView.title = "Sign in Failed!"
        alertView.message = msg
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    @IBAction func onSignIn() {
        if studentNumber.text.isEmpty || password.text.isEmpty {
            self.error("Please enter Username and Password")
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        dataProvider = NUIGWebsiteExamDataProvider()
        dataProvider!.onIncorrectPassword = {
            self.error("Incorrect Password")
        }
        dataProvider!.onIncorrectUsername = {
            self.error("Invalid Student ID")
        }
        dataProvider!.onConnectionError = { (error: NSError) in
            self.error(error.localizedDescription)
        }
        dataProvider!.onParseError = {
            self.error("NUIG exam timetable isn't accessible.\nTry using the NUIG website.")
        }
        let studentID = studentNumber.text
        let pwd = password.text
        dataProvider!.fetchTimetable(studentID, password: pwd) { (examSession: String) in
            // Save login details and preferences
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setBool(true, forKey: "isLoggedIn")
            prefs.setObject(examSession, forKey: "examSession")
            prefs.synchronize()
            KeychainService.save("studentID", studentID)
            KeychainService.save("password", pwd)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}