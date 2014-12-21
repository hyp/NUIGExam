import UIKit
import CoreData
import Foundation

// Retrieves the exam timetable from the NUIG website and parses it.
public class NUIGWebsiteExamDataProvider: NSObject, UIWebViewDelegate {
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    // This callback is called when the timetable was successfuly fetched from the website.
    var onCompletion: ((examSession: String) -> ())? = nil
    var onIncorrectPassword: (() -> ())? = nil
    var onIncorrectUsername: (() -> ())? = nil
    // This callback is called when a webview encountered loading error.
    var onConnectionError: ((NSError) -> ())? = nil
    // This callback is called when the website that was supposed to have the exam timetable
    // contained invalid data.
    var onParseError: (() -> ())? = nil
    
    private let webview: UIWebView
    private var username = ""
    private var password = ""
    private var parseErrorOccured = false
    private var initialLoad = true
    private var examSession = ""
    
    override init() {
        webview = UIWebView()
        super.init()
        
        webview.delegate = self
    }
    
    // Load and parse the exam timetable from the NUIG website.
    func fetchTimetable(username: String, password: String, completionCallback: ((examSession: String) -> ())? = nil) {
        self.username = username
        self.password = password
        
        onCompletion = completionCallback
        initialLoad = true
        parseErrorOccured = false
        
        let url = NSURL(string: "https://www.mis.nuigalway.ie/regexam/time_table_personal_form.asp")
        webview.loadRequest(NSURLRequest(URL: url!))
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        println("Done loading")
        
        // The first time we are at the exam timetable login page.
        if initialLoad {
            initialLoad = false
            
            // Simulate form entry.
            var js = "document.login_form.id_number.value = '\(username)';"
            js += "document.login_form.password.value = '\(password)';"
            js += "document.login_form.submit();"
            webview.stringByEvaluatingJavaScriptFromString(js)
            
            // Clean up sensitive data.
            username = ""
            password = ""
            return
        }
        
        // When the password was wrong, the title will contain 'Invalid Password'.
        let hasPassword = webview.stringByEvaluatingJavaScriptFromString("document.title.lastIndexOf('Password')")
        if hasPassword != "-1" {
            if let f = onIncorrectPassword {
                f()
            }
            return
        }
        
        // When the username was wrong, the title will contain 'No such student'.
        let hasStudent = webview.stringByEvaluatingJavaScriptFromString("document.title.lastIndexOf('student')")
        if hasStudent != "-1" {
            if let f = onIncorrectUsername {
                f()
            }
            return
        }
        
        // We've reached a page that probably has the timetable, try parsing it.
        parseTimetable()
        if parseErrorOccured {
            return
        }
        
        // Save the timetable and report completion.
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        if let f = onCompletion {
            f(examSession: examSession)
        }
    }
    
    private func parseError() {
        if parseErrorOccured {
            return
        }
        if let f = onParseError {
            f()
        }
        parseErrorOccured = true
    }
    
    private func eval(js: String) -> String {
        if let result = webview.stringByEvaluatingJavaScriptFromString(js) {
            return result
        }
        parseError()
        return ""
    }
    
    private func tableCell(row: Int, _ column: Int) -> String {
        return eval("document.body.getElementsByTagName('tr')[\(row)]" + ".getElementsByTagName('td')[\(column)].innerText")
    }
    
    // Return 'Semester 1 2014/2015' from a string like ' Semester 1 2014/2015 - 0000000'.
    public class func parseExamSessionName(title: String) -> String {
        let match = title.componentsSeparatedByString("-")
        if !match.isEmpty {
            return match[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return title
    }
    
    // Return 'CT318' from a string like '3BCT1-CT318-1'.
    public class func parseModuleCode(module: String) -> String {
        let match = module.componentsSeparatedByString("-")
        if match.count > 1 {
            return match[1]
        }
        return module
    }
    
    // Return 'Name' from a string like 'Name - Paper 1 - Written'.
    public class func parseModuleName(exam: String) -> String {
        let match = exam.componentsSeparatedByString("-")
        if !match.isEmpty {
            return match[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return exam
    }
    
    // Return 'Paper 1' from a string like 'Name - Paper 1 - Written'.
    public class func parseExamPaper(exam: String) -> String {
        let match = exam.componentsSeparatedByString("-")
        if match.count > 1 {
            return match[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return ""
    }

    func parseTimetable() {
        
        // Irish locale is used to parse a time value like '9:30' or '16:30'
        let dateParser = NSDateFormatter()
        dateParser.locale = NSLocale(localeIdentifier: "en-IE")
        dateParser.dateStyle = NSDateFormatterStyle.ShortStyle
        dateParser.timeStyle = NSDateFormatterStyle.ShortStyle
        
        // Get the name of the current examination period
        let title = eval("document.title.substr( document.title.indexOf('for:') + 4 )")
        examSession = NUIGWebsiteExamDataProvider.parseExamSessionName(title)
        
        let rowCount = eval("document.body.getElementsByTagName('tr').length")
        if var rows = rowCount.toInt() {
            if rows == 0 {
                parseError()
            }
            if tableCell(0, 0) != "Day" {
                parseError()
            }
            for var row = 1; row < rows; row+=4 {
                let date = tableCell(row, 1)
                let time = tableCell(row, 2)
                if let d = dateParser.dateFromString("\(date) \(time)") {
                    let module = NUIGWebsiteExamDataProvider.parseModuleCode(tableCell(row, 3))
                    var duration = tableCell(row, 4).toInt() ?? 0
                    let examInfo = tableCell(row + 1, 1)
                    let name = NUIGWebsiteExamDataProvider.parseModuleName(examInfo)
                    let venue = tableCell(row + 2, 1).capitalizedString.stringByReplacingOccurrencesOfString("Nuig", withString: "NUIG")
                    let paper = NUIGWebsiteExamDataProvider.parseExamPaper(examInfo)
                    Exam.create(self.managedObjectContext!, code: module, name: name, date: d, venue: venue, duration: duration, paper: paper)
                } else {
                    parseError()
                }
            }
        } else {
            parseError()
        }
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        if let f = onConnectionError {
            f(error)
            onConnectionError = nil
        }
    }
    
}
