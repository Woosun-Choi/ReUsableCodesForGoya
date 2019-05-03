//
//  DissmisAnimator.swift
//  linearCollectionViewTest
//
//  Created by goya on 02/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class ZommingTransitionDelegate_DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    init(targetRect: CGRect) {
        openingFrame = targetRect
    }
    
    convenience init(targetRect: CGRect, setBeforeAnimate: ((UIViewController) -> Void)?, setAfterAnimate: ((UIViewController) -> Void)?) {
        self.init(targetRect: targetRect)
        convenienceTargetViewOriginSetting = setBeforeAnimate
        convenienceTargetViewFinalSetting = setAfterAnimate
    }
    
    private var openingFrame: CGRect?
    
    var convenienceTargetViewOriginSetting : ((UIViewController) -> Void)?
    
    var convenienceTargetViewFinalSetting : ((UIViewController) -> Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originFrame = openingFrame,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        
        let containerView = transitionContext.containerView
        
        var finalFrame = originFrame
        
        let animationDuration = self .transitionDuration(using: transitionContext)
        
//        if let targetView = toViewController as? ZoomingStyleTransitionDataSource {
//            convenienceTargetViewOriginSetting = targetView.targetViewSetting_PrepareDismissing
//            convenienceTargetViewFinalSetting = targetView.targetViewSetting_FinishDismissing
//        }
        
        convenienceTargetViewOriginSetting?(fromViewController)
        
        UIView.animate(withDuration: animationDuration * 2, animations: {
            fromViewController.view.frame = finalFrame
            self.convenienceTargetViewFinalSetting?(fromViewController)
            fromViewController.view.layoutIfNeeded()
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

//MARK : snapshot version transition
//        if let myView = fromViewController as? ImageDetailView {
//            targetFrom = myView.imageView.bounds
//        }
//        let snapshotView = fromViewController.view.resizableSnapshotView(from: targetFrom, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
//        containerView.addSubview(snapshotView ?? UIView())
//
//        //toViewController.view.alpha = 0
//
//        UIView.animate(withDuration: animationDuration * 2, animations: {
//            fromViewController.view.alpha = 0.0
//            snapshotView?.frame = self.openingFrame!
//        }) { (finished) in
//            UIView.animate(withDuration: animationDuration * 2, animations: {
//                //snapshotView?.frame = self.openingFrame!
//                snapshotView?.alpha = 0.0
//                toViewController.view.alpha = 1
//            }) { (finished) in
//                //snapshotView?.alpha = 0.0
//                snapshotView?.removeFromSuperview()
//                fromViewController.view.removeFromSuperview()
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            }
//        }
