import CoreLocation
@testable import NSDK
import XCTest

final class NSDKLocationAccessEvaluatorTests: XCTestCase {
    func testMissingUsageDescriptionTakesPrecedence() {
        let error = NSDKLocationAccessEvaluator.error(
            hasUsageDescription: false,
            servicesEnabled: true,
            authorizationStatus: .authorizedWhenInUse
        )

        XCTAssertEqual(error, .missingUsageDescription)
    }

    func testDisabledLocationServicesReturnsServicesDisabled() {
        let error = NSDKLocationAccessEvaluator.error(
            hasUsageDescription: true,
            servicesEnabled: false,
            authorizationStatus: .authorizedWhenInUse
        )

        XCTAssertEqual(error, .servicesDisabled)
    }

    func testDeniedAuthorizationReturnsAuthorizationDenied() {
        let error = NSDKLocationAccessEvaluator.error(
            hasUsageDescription: true,
            servicesEnabled: true,
            authorizationStatus: .denied
        )

        XCTAssertEqual(error, .authorizationDenied)
    }

    func testRestrictedAuthorizationReturnsAuthorizationRestricted() {
        let error = NSDKLocationAccessEvaluator.error(
            hasUsageDescription: true,
            servicesEnabled: true,
            authorizationStatus: .restricted
        )

        XCTAssertEqual(error, .authorizationRestricted)
    }

    func testNotDeterminedAuthorizationDoesNotFailPreflight() {
        let error = NSDKLocationAccessEvaluator.error(
            hasUsageDescription: true,
            servicesEnabled: true,
            authorizationStatus: .notDetermined
        )

        XCTAssertNil(error)
    }

    func testAuthorizedWhenInUseDoesNotFailPreflight() {
        let error = NSDKLocationAccessEvaluator.error(
            hasUsageDescription: true,
            servicesEnabled: true,
            authorizationStatus: .authorizedWhenInUse
        )

        XCTAssertNil(error)
    }
}
