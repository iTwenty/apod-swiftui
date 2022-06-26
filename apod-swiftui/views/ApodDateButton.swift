//
//  ApodDateButton.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 24/06/22.
//

import Foundation
import SwiftUI

class InputUIButton: UIButton {
    private var myInputView = UIView()
    private var myInputAccessoryView: UIView?

    override var inputView: UIView {
        get {
            return self.myInputView
        }
        set {
            self.myInputView = newValue
        }
    }

    override var inputAccessoryView: UIView? {
        get {
            return self.myInputAccessoryView
        }
        set {
            self.myInputAccessoryView = newValue
        }
    }

    override var canBecomeFirstResponder: Bool { true }
}

struct ApodDateButton: UIViewRepresentable {
    @Binding var date: Date
    let doneAction: () -> ()

    func makeUIView(context: Context) -> InputUIButton {
        let view = UIDatePicker()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.datePickerMode = .date
        view.calendar = Constants.Calendars.apodCalendar
        view.minimumDate = Constants.Dates.apodLaunchDate
        view.maximumDate = Constants.Dates.startOfDay
        view.preferredDatePickerStyle = .inline
        context.coordinator.datePicker = view

        // Give the toolbar 100x100 rect to begin with, or else it throws all
        // sorts of autolayout constraint errors when laying out the buttons.
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        bar.translatesAutoresizingMaskIntoConstraints = false
        let todayButton = UIBarButtonItem(title: "Today", style: .plain,
                                          target: context.coordinator,
                                          action: #selector(context.coordinator.didClickTodayButton))
        let flexiSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                         target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain,
                                         target: context.coordinator,
                                         action: #selector(context.coordinator.didClickDoneButton))
        bar.items = [todayButton, flexiSpace, doneButton]
        bar.sizeToFit()

        let button = InputUIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(context.coordinator,
                         action: #selector(context.coordinator.didClickApodDateButton),
                         for: .touchUpInside)
        button.inputView = view
        button.inputAccessoryView = bar
        context.coordinator.uiButton = button
        return button
    }

    func updateUIView(_ uiButton: InputUIButton, context: Context) {
        uiButton.setTitle(date.displayFormatted(), for: .normal)
        if context.coordinator.datePicker?.date != date {
            context.coordinator.datePicker?.date = date
        }
    }

    func makeCoordinator() -> ApodDateButtonCoordinator {
        return ApodDateButtonCoordinator(self)
    }
}

class ApodDateButtonCoordinator: NSObject {
    private var apodDateButton: ApodDateButton
    var uiButton: InputUIButton?
    var datePicker: UIDatePicker?

    init(_ button: ApodDateButton) {
        self.apodDateButton = button
    }

    @objc func didClickTodayButton() {
        apodDateButton.date = Constants.Dates.startOfDay
    }

    @objc func didClickDoneButton() {
        apodDateButton.date = datePicker?.date ?? Constants.Dates.startOfDay
        uiButton?.resignFirstResponder()
        apodDateButton.doneAction()
    }

    @objc func didClickApodDateButton() {
        uiButton?.becomeFirstResponder()
    }
}
