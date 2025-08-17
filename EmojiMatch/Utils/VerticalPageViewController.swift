import SwiftUI
import UIKit

struct VerticalPageViewController: UIViewControllerRepresentable {
    var pages: [AnyView]
    @Binding var currentPage: Int
    var isScrollEnabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: nil
        )

        pageVC.dataSource = context.coordinator
        pageVC.delegate = context.coordinator

        if let scrollView = pageVC.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            context.coordinator.scrollView = scrollView
            scrollView.isScrollEnabled = isScrollEnabled
        }

        if let firstController = context.coordinator.controllers.first {
            pageVC.setViewControllers([firstController], direction: .forward, animated: true)
        }

        return pageVC
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        if let scrollView = context.coordinator.scrollView {
            scrollView.isScrollEnabled = isScrollEnabled
        }

        pageViewController.setViewControllers(
            [context.coordinator.controllers[currentPage]],
            direction: .forward,
            animated: true
        )
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: VerticalPageViewController
        var controllers: [UIViewController]
        weak var scrollView: UIScrollView?

        init(_ parent: VerticalPageViewController) {
            self.parent = parent
            self.controllers = parent.pages.map { UIHostingController(rootView: $0) }
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController), index > 0 else {
                return nil
            }
            return controllers[index - 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController), index + 1 < controllers.count else {
                return nil
            }
            return controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            if completed,
               let visible = pageViewController.viewControllers?.first,
               let index = controllers.firstIndex(of: visible) {
                parent.currentPage = index
            }
        }
    }
}
