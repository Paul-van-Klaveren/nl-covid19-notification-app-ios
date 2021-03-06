/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

enum HelpOverviewEntry: HelpDetailEntry, LinkedContent {
    case question(_ question: HelpQuestion)
    case notificationExplanation(title: String, linkedContent: [LinkedContent])

    var title: String {
        switch self {
        case let .question(question):
            return question.question
        case let .notificationExplanation(title, _):
            return title
        }
    }

    var answer: String {
        switch self {
        case let .question(question):
            return question.answer
        default:
            return ""
        }
    }

    var linkedEntries: [LinkedContent] {
        switch self {
        case let .question(question):
            return question.linkedContent
        case let .notificationExplanation(_, linkedContent):
            return linkedContent
        }
    }
}
