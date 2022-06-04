//
//  PageView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 01/03/22.
//

import Foundation
import SwiftUI

struct PageView<Data, Page: View>: UIViewControllerRepresentable {
    let initialData: Data
    @ViewBuilder let pageBuilder: (Data) -> Page
    let before: (Data) -> Data?
    let after: (Data) -> Data?

    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        let initialVc = PageViewController(data: initialData, rootView: pageBuilder(initialData))
        vc.setViewControllers([initialVc], direction: .reverse, animated: false)
        vc.dataSource = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: UIPageViewController, context: Context) { }

    func makeCoordinator() -> PageViewCoordinator<Data, Page> {
        PageViewCoordinator(pageBuilder: pageBuilder, before: before, after: after)
    }
}

private class PageViewController<Data, Page: View>: UIHostingController<Page> {
    let data: Data

    init(data: Data, rootView: Page) {
        self.data = data
        super.init(rootView: rootView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PageViewCoordinator<Data, Page: View>: NSObject, UIPageViewControllerDataSource {
    private let pageBuilder:  (Data) -> Page
    private let before: (Data) -> Data?
    private let after: (Data) -> Data?

    init(pageBuilder: @escaping (Data) -> Page,
         before: @escaping (Data) -> Data?,
         after: @escaping (Data) -> Data?) {
        self.pageBuilder = pageBuilder
        self.before = before
        self.after = after
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentData = (viewController as? PageViewController<Data, Page>)?.data else {
            return nil
        }

        guard let beforeData = self.before(currentData) else {
            return nil
        }

        return PageViewController(data: beforeData, rootView: pageBuilder(beforeData))
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentData = (viewController as? PageViewController<Data, Page>)?.data else {
            return nil
        }

        guard let afterData = self.after(currentData) else {
            return nil
        }

        return PageViewController(data: afterData, rootView: pageBuilder(afterData))
    }
}
