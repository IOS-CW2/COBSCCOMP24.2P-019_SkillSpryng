import XCTest

final class UnitTestSummaryObserver: NSObject, XCTestObservation {
    static let shared = UnitTestSummaryObserver()

    private var passed = 0
    private var failed = 0
    private var total = 0

    private override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        total += 1
        if let run = testCase.testRun, run.hasSucceeded {
            passed += 1
        } else {
            failed += 1
        }
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        print("✅ Unit Test Summary: \(total) tests run — \(passed) passed, \(failed) failed")
    }
}
