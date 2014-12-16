import UIKit
import XCTest
import NUIGExam

class NUIGExamTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNUIGWebsiteExamSessionNameParsing() {
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseExamSessionName(" Semester 1 2014/2015 - 0000000"), "Semester 1 2014/2015")
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseExamSessionName("Semester 1"), "Semester 1")
    }
    
    func testNUIGWebsiteModuleNameParsing() {
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseModuleName("Name - Paper 1 - Written"), "Name")
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseModuleName("Name"), "Name")
    }
    
    func testNUIGWebsiteModuleCodeParsing() {
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseModuleCode("3BCT1-CT318-1"), "CT318")
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseModuleCode("CT318"), "CT318")
    }
    
    func testNUIGWebsiteExampPaperParsing() {
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseExamPaper("Name - Paper 1 - Written"), "Paper 1")
        XCTAssertEqual(NUIGWebsiteExamDataProvider.parseExamPaper("Name"), "")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
