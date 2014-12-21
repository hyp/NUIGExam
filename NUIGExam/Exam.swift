import Foundation
import CoreData
import MapKit

// A Serializable Exam Entity
public class Exam: NSManagedObject {

    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var seatNumber: NSNumber
    @NSManaged var venue: String
    @NSManaged var paper: String
    @NSManaged var duration: NSNumber // the duration of the exam in minutes
    
    // Returns true when an exam is 'done' i.e. 60 minutes after it started.
    public var isFinished: Bool {
        get {
            return date.dateByAddingTimeInterval(60*60).compare(NSDate()) == NSComparisonResult.OrderedAscending
        }
    }
    
    // Returns the physical location of the exam venue
    public var location: CLLocationCoordinate2D {
        get {
            for (name, loc) in locationCoordinates {
                if let _ = venue.rangeOfString(name, options: .CaseInsensitiveSearch) {
                    return loc
                }
            }
            
            // NUIG's location
            return CLLocationCoordinate2D(latitude: 53.278552, longitude: -9.060518)
        }
    }

    // Returns the duration of the exam
    public var durationString: String {
        get {
            if duration.integerValue == 0 {
                return "Unknown"
            }
            return duration.integerValue % 60 == 0 ? "\(duration.integerValue/60) Hours" : "\(duration.integerValue/60) Hours \(duration.integerValue%60) Minutes"
        }
    }

    public class func create(ctx: NSManagedObjectContext, code: String, name: String, date: NSDate, venue: String, duration: Int, paper: String = "Paper 1") -> Exam {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Exam", inManagedObjectContext: ctx) as Exam
        newItem.code = code
        newItem.name = name
        newItem.date = date
        newItem.seatNumber = NSNumber()
        newItem.venue = venue
        newItem.paper = paper
        newItem.duration = NSNumber(integer: duration)
        return newItem
    }
}

let locationCoordinates = [
    "leisureland":          CLLocationCoordinate2D(latitude: 53.259039, longitude: -9.082346),
    "galway bay hotel":     CLLocationCoordinate2D(latitude: 53.258217, longitude: -9.084942),
    "westwood house hotel": CLLocationCoordinate2D(latitude: 53.2825866, longitude: -9.0638771),
    "westwood hotel":       CLLocationCoordinate2D(latitude: 53.2825866, longitude: -9.0638771),
    "kingfisher":           CLLocationCoordinate2D(latitude: 53.282077, longitude: -9.062358),
    "bailey allen":         CLLocationCoordinate2D(latitude: 53.278436, longitude: -9.058013),
    "the cube":             CLLocationCoordinate2D(latitude: 53.278436, longitude: -9.058013)
]
