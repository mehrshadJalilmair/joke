//
//  EMPartialModalViewController.swift
//  EMPartialModalViewController
//
//  Created by Emad A. on 25/01/2015.
//  Copyright (c) 2015 Emad A. All rights reserved.
//

import UIKit

class EMPartialModalViewController: UIViewController {

    // MARK: - Public Properties

    // The max height of content navigation view controller
    var contentViewMaxHeight: CGFloat = UIScreen.main.bounds.height {
        didSet {
            if contentViewController != nil {
                var frame: CGRect = contentViewController!.view.frame
                frame.size.height = contentViewMaxHeight
                frame.origin.y = view.bounds.maxY - frame.height

                contentViewController!.view.frame = frame
            }
        }
    }

    // MARK: - Private Properties

    // The height of content navigation view controller
    fileprivate var contentViewHeight: CGFloat = 0

    // A snapshot of man screen with status bar
    fileprivate var snapshotView: UIView?// = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false)

    // An overlay view, as button to dismiss the modal view controller on being touched
    fileprivate let overlayView: UIButton = UIButton(type: UIButtonType.custom)

    // A view controller holds the main content of modal
    fileprivate var contentViewController: UIViewController?

    // MARK: - Initializers

    convenience init(rootViewController: UIViewController) {
        self.init(rootViewController: rootViewController, contentHeight: rootViewController.view.bounds.height)
    }

    convenience init(rootViewController: UIViewController, contentHeight: CGFloat) {
        self.init()

        contentViewHeight = contentHeight

        contentViewController = rootViewController
        if contentViewController != nil {
            view.addSubview(contentViewController!.view)
            addChildViewController(contentViewController!)
        }
    }

    // MARK: - Overriden Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting view controler properties to have customized presentation transition
        transitioningDelegate = self
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = UIModalPresentationStyle.custom

        // The view should have balck background color.
        view.isOpaque = true
        view.backgroundColor = UIColor.black

        // Initializing overlay
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        overlayView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        overlayView.addTarget(self, action: #selector(EMPartialModalViewController.dismissViewController), for: UIControlEvents.touchUpInside)

        view.addSubview(overlayView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if contentViewController != nil {
            contentViewHeight = min(contentViewHeight, self.contentViewMaxHeight)
            var frame = CGRect.zero
            frame.size = CGSize(width: view.bounds.width, height: contentViewHeight)
            frame.origin = CGPoint(x: view.bounds.minX, y: view.bounds.maxY - frame.height)
            contentViewController!.view.frame = frame
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Public Methods

    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}

extension EMPartialModalViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension EMPartialModalViewController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.42
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let animationDuration: TimeInterval = transitionDuration(using: transitionContext)
        let containerView: UIView = transitionContext.containerView

        fromViewController.viewWillDisappear(transitionContext.isAnimated)
        toViewController.viewWillAppear(transitionContext.isAnimated)

        // To present the view controller
        if let viewController = toViewController as? EMPartialModalViewController {
            if viewController.contentViewController == nil {
                return;
            }

            // Setting the srart point of overlay alpha animation
            viewController.overlayView.alpha = 0;

            // Inserting the snapshot of the window root view controller at the back all views of modal view controller
            // The snapshot is going to be scaled down
            viewController.snapshotView = fromViewController.view.resizableSnapshotView(
                from: toViewController.view.frame,
                afterScreenUpdates: false,
                withCapInsets: UIEdgeInsets.zero)
            let snapshot: UIView = viewController.snapshotView!
            viewController.view.insertSubview(snapshot, at: 0)

            // Frame for snapshot to scale it down
            var frame: CGRect = snapshot.frame
            let snapshotScale = UIApplication.shared.statusBarFrame.height / frame.height
            frame = frame.insetBy(dx: frame.width * snapshotScale, dy: frame.height * snapshotScale)

            // Putting the modal view content at the bottom of the view
            let view = viewController.contentViewController!.view
            view?.transform = CGAffineTransform(translationX: 0, y: (view?.bounds.height)!)

            // Adding the modal view controller into view
            containerView.addSubview(viewController.view)

            // Starting animation
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity:  1,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: { () -> Void in
                    viewController.overlayView.alpha = 1
                    view?.transform = CGAffineTransform(translationX: 0, y: 0)
                    snapshot.frame = frame
                },
                completion: { (Bool) -> Void in
                    transitionContext.completeTransition(true)
                    viewController.viewDidAppear(transitionContext.isAnimated)
                    fromViewController.viewDidDisappear(transitionContext.isAnimated)
                })
        }

        // To dismiss the view controller
        else if let viewController = fromViewController as? EMPartialModalViewController {
            if viewController.contentViewController == nil {
                return;
            }

            // Getting the view of the content view controller
            let view: UIView = viewController.contentViewController!.view

            // Start animation
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity:  1,
                options: UIViewAnimationOptions.curveEaseOut,
                animations: { () -> Void in
                    viewController.overlayView.alpha = 0;
                    view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
                    viewController.snapshotView?.frame = viewController.view.bounds
                },
                completion: { (Bool) -> Void in
                    transitionContext.completeTransition(true)
                    toViewController.viewDidAppear(transitionContext.isAnimated)
                    fromViewController.viewDidDisappear(transitionContext.isAnimated)
            })
        }
    }
}
