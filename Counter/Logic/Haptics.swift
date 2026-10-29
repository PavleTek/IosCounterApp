//
//  Haptics.swift
//  Counter
//

import UIKit

enum Haptics {
    private static let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    static func prepare() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
    }

    static func impact(enabled: Bool) {
        guard enabled else { return }
        impactGenerator.impactOccurred()
        impactGenerator.prepare()
    }

    static func notify(enabled: Bool) {
        guard enabled else { return }
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }
}
