//
//  PageView.swift
//  apod-swiftui
//
//  Created by Jaydeep Joshi on 01/03/22.
//

import Foundation
import SwiftUI

enum PageChangeSource {
    case initial
    case direct
    case gestureForward
    case gestureReverse
}

struct PageView<Data: Comparable, Page: View>: UIViewControllerRepresentable {
    @Binding var data: Data
    @ViewBuilder let pageBuilder: (Data) -> Page
    let before: (Data) -> Data?
    let after: (Data) -> Data?
    let onPageChange: ((Data, PageChangeSource) -> ())?

    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        let initialVc = PageViewController(data: data, rootView: pageBuilder(data))
        vc.setViewControllers([initialVc], direction: .reverse, animated: false)
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        onPageChange?(data, .initial)
        return vc
    }

    func updateUIViewController(_ vc: UIPageViewController, context: Context) {
        guard !context.coordinator.ignoreUpdate else {
            context.coordinator.ignoreUpdate = false
            return
        }
        guard let currentData = (vc.viewControllers?.first as? PageViewController<Data, Page>)?.data else {
            return
        }
        if currentData == data {
            return
        }
        let direction: UIPageViewController.NavigationDirection = currentData > data ? .reverse : .forward
        let initialVc = PageViewController(data: data, rootView: pageBuilder(data))
        vc.setViewControllers([initialVc], direction: direction, animated: false) { completed in
            onPageChange?(data, .direct)
        }
    }

    func makeCoordinator() -> PageViewCoordinator<Data, Page> {
        PageViewCoordinator(self)
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

class PageViewCoordinator<Data: Comparable, Page: View>: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private var pageView: PageView<Data, Page>
    var ignoreUpdate = false

    init(_ pageView: PageView<Data, Page>) {
        self.pageView = pageView
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentData = (viewController as? PageViewController<Data, Page>)?.data else {
            return nil
        }

        guard let beforeData = pageView.before(currentData) else {
            return nil
        }

        return PageViewController(data: beforeData, rootView: pageView.pageBuilder(beforeData))
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentData = (viewController as? PageViewController<Data, Page>)?.data else {
            return nil
        }

        guard let afterData = pageView.after(currentData) else {
            return nil
        }

        return PageViewController(data: afterData, rootView: pageView.pageBuilder(afterData))
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let currentData = (pageViewController.viewControllers?.first as? PageViewController<Data, Page>)?.data else {
            return
        }
        ignoreUpdate = true
        pageView.data = currentData
        pageView.onPageChange?(currentData, .gestureReverse)
    }
}
