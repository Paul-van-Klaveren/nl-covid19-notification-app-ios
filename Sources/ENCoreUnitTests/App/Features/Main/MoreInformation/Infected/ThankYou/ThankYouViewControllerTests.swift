/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import ENCore
import Foundation
import SnapshotTesting
import XCTest

final class ThankYouViewControllerTests: XCTestCase {
    private var viewController: ThankYouViewController!
    private let listenr = ThankYouListenerMock()

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        SnapshotTesting.record = false

        let theme = ENTheme()

        viewController = ThankYouViewController(listener: listenr,
                                                theme: theme)
    }

    // MARK: - Tests

    func testSnapshotStateLoading() {
        assertSnapshot(matching: viewController, as: .image())
    }
}
