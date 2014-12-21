import UIKit
import MapKit
import EventKit

class ExamViewController: UITableViewController, MKMapViewDelegate, UIActionSheetDelegate {
    var exam : Exam? = nil
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var examName: UILabel!
    @IBOutlet weak var examPaper: UILabel!
    @IBOutlet weak var venue: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var length: UILabel!
    var dateTimeFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        dateTimeFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateTimeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateTimeFormatter.locale = NSLocale(localeIdentifier: "en-IE")
        
        if let exam = exam {
            navigationItem.title = exam.code
            examName.text = exam.name
            examPaper.text = exam.paper
            venue.text = exam.venue
            date.text = dateTimeFormatter.stringFromDate(exam.date)
            length.text = exam.durationString
            
            let location = exam.location
            let span = MKCoordinateSpanMake(0.008, 0.008)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: false)
            
            // Shown a pin at the exam location
            let annotation = MKPointAnnotation()
            annotation.setCoordinate(location)
            mapView.addAnnotation(annotation)
        }
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "onAction")
    }
    
    // MARK: - Action Sheet

    func onAction() {
        let actions = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Get Directions", "Add To Calendar")
        actions.showFromBarButtonItem(navigationItem.rightBarButtonItem, animated: true)
    }
    
    func actionSheet(myActionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch(buttonIndex) {
        case 1:
            // Get directions
            let location = exam!.location
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary: nil))
            destination.name = exam?.venue
            destination.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        case 2:
            // Add to calendar
            let store = EKEventStore()
            let event = EKEvent(eventStore: store)
            event.title = "\(exam!.name) Exam"
            event.startDate = exam!.date
            event.endDate = exam!.date.dateByAddingTimeInterval(exam!.duration.doubleValue * 60)
            store.requestAccessToEntityType(EKEntityTypeEvent) { (granted: Bool, error: NSError!) in
                if granted {
                    event.calendar = store.defaultCalendarForNewEvents
                    var err: NSError? = nil
                    store.saveEvent(event, span: EKSpanThisEvent, error: &err)
                }
            }
            break
        default:
            break
        }
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0: return 88
        case 1:
            // Compute the height of this cell taking the venue text into consideration.
            let str = venue.text! as NSString
            let size = str.boundingRectWithSize(CGSize(width: tableView.bounds.width - 30, height: 100), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: venue.font], context: nil)
            return 60 + (round(size.height/venue.font.lineHeight) - 1)*20
        default: return 60
        }
    }
    
    // MARK: - Map View
    
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        mapView.hidden = true
    }

}
