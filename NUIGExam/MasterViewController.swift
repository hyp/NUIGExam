import UIKit
import CoreData

// A TableViewCell that displays the Exam details.
class ExamCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    
}

// Displays the exam timetable.
class MasterViewController: UITableViewController {
    var exams: [[Exam]] = []
    var dateFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if !prefs.boolForKey("isLoggedIn") {
            self.performSegueWithIdentifier("showLogin", sender: self)
        } else {
            if let examSession = prefs.stringForKey("examSession") {
                self.navigationItem.title = examSession + " Exams"
            }
            fetchExams()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.locale = NSLocale(localeIdentifier: "en-IE")
        
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.doesRelativeDateFormatting = true
        
        // Scroll to show the next exam.
        /*
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Return true if two dates are on the same day.
    func areDatesOnSameDay(x: NSDate, _ y: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: x) == calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: y) && calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: x) == calendar.component(NSCalendarUnit.CalendarUnitMonth, fromDate: y) && calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: x) == calendar.component(NSCalendarUnit.CalendarUnitDay, fromDate: y)
    }
    
    // Load the exams from CoreData storage.
    func fetchExams() {
        let fetchRequest = NSFetchRequest(entityName: "Exam")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Exam] {
            exams.removeAll(keepCapacity: true)
            for exam in result {
                let date = exam.date
                var i = 0
                for ; i < exams.count; i++ {
                    if areDatesOnSameDay(date, exams[i][0].date) {
                        break
                    }
                }
                if i >= exams.count {
                    exams.append([])
                }
                
                exams[i].append(exam)
            }
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table View
    
    func selectedExam() -> Exam? {
        if let selection = tableView.indexPathForSelectedRow() {
            return exams[selection.section][selection.row]
        }
        return nil
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !exams.isEmpty {
            self.tableView.backgroundView = nil
            return exams.count
        }
        
        // No exams - show message to the user.
        let message = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        message.text = "No exams in this session"
        message.textColor = UIColor.blackColor()
        message.numberOfLines = 0
        message.textAlignment = NSTextAlignment.Center
        message.font = UIFont.italicSystemFontOfSize(20)
        message.sizeToFit()
        
        self.tableView.backgroundView = message
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams[section].count

    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateFormatter.stringFromDate(exams[section].first!.date)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let exam = exams[indexPath.section][indexPath.row]
        if exam.isFinished {
            return 40
        }
        return 61
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as ExamCell
        let exam = exams[indexPath.section][indexPath.row]
        
        cell.nameLabel.text = exam.name
        if exam.isFinished {
            cell.nameLabel.enabled = false
            cell.descriptionLabel.hidden = true
            return cell
        }
        let date = timeFormatter.stringFromDate(exam.date)
        if exam.seatNumber.boolValue {
            cell.descriptionLabel.text = "\(date) · Seat \(exam.seatNumber) · \(exam.venue)"
        } else {
            cell.descriptionLabel.text = "\(date) · \(exam.venue)"
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showExam" {
            (segue.destinationViewController as ExamViewController).exam = selectedExam()
        }
    }

}

