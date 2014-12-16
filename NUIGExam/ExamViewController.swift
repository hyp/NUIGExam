import UIKit
import MapKit

class ExamViewController: UITableViewController, MKMapViewDelegate {
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
            length.text = "2 Hours"
            
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
    
    func onAction() {
        let actions = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Get directions", "Add to calendar")
        actions.showFromBarButtonItem(navigationItem.rightBarButtonItem, animated: true)
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
