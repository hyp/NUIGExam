import Foundation
import CoreData

// A Serializable Exam Entity
class Exam: NSManagedObject {

    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var seatNumber: NSNumber
    @NSManaged var venue: String
    
    // Returns true when an exam is 'done' i.e. 60 minutes after it started.
    var isFinished: Bool {
        get {
            return date.dateByAddingTimeInterval(60*60).compare(NSDate()) == NSComparisonResult.OrderedAscending
        }
    }

    class func create(ctx: NSManagedObjectContext, code: String, name: String, date: NSDate, venue: String) -> Exam {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Exam", inManagedObjectContext: ctx) as Exam
        newItem.code = code
        newItem.name = name
        newItem.date = date
        newItem.seatNumber = NSNumber()
        newItem.venue = venue
        return newItem
    }
}
