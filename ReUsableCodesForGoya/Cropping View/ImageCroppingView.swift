//
//  ImageCroppingView.swift
//  ImageCroptest_Version2
//
//  Created by goya on 14/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct ImageCropDataManager {
    
    static var originalImage : UIImage?
    
    static var croppedImage : UIImage?
    
    static var willSaveImage : UIImage?
    
}

class ImageCroppingView: UIView, UIScrollViewDelegate {
    
    class CroppingArea: UIVisualEffectView {
        
        var transparentHoleRect: CGRect! {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            if self.transparentHoleRect != nil {
                // Ensures to use the current background color to set the filling color
//                self.backgroundColor?.setFill()
//                UIRectFill(rect)
                
                let transparentLayer = CAShapeLayer()
                let path = CGMutablePath()
                
                // Make hole in view's overlay
                // NOTE: Here, instead of using the transparentHoleView UIView we could use a specific CFRect location instead...
                path.addRect(transparentHoleRect)
                path.addRect(bounds)
                
                transparentLayer.path = path
                transparentLayer.fillRule = CAShapeLayerFillRule.evenOdd
                self.layer.mask = transparentLayer
            }
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return false
        }
    }
    
    var requiredActionAfterCroppingFinished: (() -> Void)?
    
    weak var imageScrollView: UIScrollView!
    
    weak var croppingView: CroppingArea!
    
    weak var imageView: UIImageView!
    
    weak var noticeLabel: UILabel!
    
    var isHorizontalCrop: Bool = true
    
    enum CropViewAreaShape {
        case horizontal
        case vertical
        case centerSquare
    }
    
    var cropAreaShape: CropViewAreaShape = .vertical
    
    var willCropAreaRect: CGRect {
        switch cropAreaShape {
        case .centerSquare: return centeredSuqareFrame
        case .horizontal: return horizontalCenteredRectangleFrame
        case .vertical: return verticalCenteredRectagleFrame
        }
    }
    
    var image: Data? {
        didSet {
            if let imageData = self.image {
                if let presentImage = UIImage(data: imageData) {
                    setImageToImageView(presentImage)
                }
            } else {
                setImageToImageView(nil)
            }
        }
    }
    
    private var defaultImage : UIImage {
        if let img = ImageCropDataManager.originalImage {
            return img
        } else {
            return UIImage()
        }
    }
    
    var willCroppedImage : UIImage {
        if let image = ImageCropDataManager.croppedImage {
            return image
        } else {
            return defaultImage
        }
    }
    
    private func setOrRePositioning_NoticeLabel() {
        if noticeLabel == nil {
            let label = UILabel()
            label.setLabelAsSDStyleWithSpecificFontSize(type: .medium, fontSize: fullFrame.height * 0.05)
            label.frame = fullFrame
            label.textColor = UIColor.goyaWhite.withAlphaComponent(0.7)
            label.textAlignment = .center
            label.text = "select a photo"
            label.sizeToFit()
            noticeLabel = label
            let originX = (self.frame.width - noticeLabel.frame.width)/2
            let originY = (self.frame.height - noticeLabel.frame.height)/2
            noticeLabel.frame.origin = CGPoint(x: originX, y: originY)
            addSubview(label)
        } else {
            let originX = (self.frame.width - noticeLabel.frame.width)/2
            let originY = (self.frame.height - noticeLabel.frame.height)/2
            noticeLabel.frame.origin = CGPoint(x: originX, y: originY)
        }
    }
    
    private func setOrRePositioning_ImageScrollViewArea() {
        
        if imageScrollView == nil {
            let scrollview = UIScrollView()
            scrollview.frame = fullFrame
            scrollview.minimumZoomScale = 1
            scrollview.maximumZoomScale = 5
            scrollview.showsVerticalScrollIndicator = false
            scrollview.showsHorizontalScrollIndicator = false
            scrollview.backgroundColor = UIColor.gray
            imageScrollView = scrollview
            addSubview(scrollview)
        } else {
            imageScrollView.frame = fullFrame
        }
    }
    
    private func setOrRePositioning_CroppingViewArea() {
        if croppingView == nil {
            let view = CroppingArea()
            //view.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0.6)
            view.effect = UIBlurEffect.init(style: .light)
            view.isOpaque = false
            view.frame = fullFrame
            croppingView = view
            croppingView.transparentHoleRect = willCropAreaRect
            addSubview(view)
        } else {
            croppingView.frame = fullFrame
            croppingView.transparentHoleRect = willCropAreaRect
        }
    }
    
    private func setOrRepositioning_imageViewArea() {
        if imageView == nil {
            let view = UIImageView()
            view.frame.size = imageScrollView.frame.size
            view.frame.origin = CGPoint.zero
            view.contentMode = .scaleAspectFit
            imageScrollView.addSubview(view)
            imageView = view
        } else {
            imageView.frame.size = imageScrollView.frame.size
            imageView.frame.origin = CGPoint.zero
        }
    }
    
    private func checkImageAndControllCroppingAreaBeHidden() {
        if self.image == nil {
            croppingView?.isHidden = true
            noticeLabel?.isHidden = false
            imageScrollView.backgroundColor = .goyaBlack
        } else {
            croppingView?.isHidden = false
            noticeLabel?.isHidden = true
            imageScrollView.backgroundColor = .clear
        }
    }
    
    private func setImageToImageView(_ image: UIImage?) {
        if let settedImage = image {
            imageView.image = settedImage.fixOrientation()
            imageScrollView.zoomScale = 1
            reSizeImageView()
            updateContentSize(true)
        } else {
            imageView.image = nil
            imageScrollView.zoomScale = 1
        }
        checkImageAndControllCroppingAreaBeHidden()
    }
    
    private func configureSubviews() {
        setOrRePositioning_ImageScrollViewArea()
        setOrRePositioning_CroppingViewArea()
        setOrRepositioning_imageViewArea()
        setOrRePositioning_NoticeLabel()
        
        if let imageData = self.image {
            if let presentImage = UIImage(data: imageData) {
                setImageToImageView(presentImage)
            }
        } else {
            setImageToImageView(nil)
        }
    }
    
    private var imageStatus : (size: CGSize, ratio: CGFloat) {
        let imageSize = imageView.imageFrame.size
        let imageRatio = imageSize.width/imageSize.height
        return (size: imageSize, ratio: imageRatio)
    }
    
    private var croppingViewStates: (size: CGSize, ratio: CGFloat) {
        let size = willCropAreaRect.size
        let ratio = willCropAreaRect.width/willCropAreaRect.height
        return (size: size, ratio: ratio)
    }
    
    private func reSizeImageView() {
        if imageStatus.ratio > 1 {
            var estimatedHeight = willCropAreaRect.height
            var estimatedWidth : CGFloat {
                return estimatedHeight * imageStatus.ratio
            }
            if estimatedWidth < willCropAreaRect.width {
                while estimatedWidth < willCropAreaRect.width {
                    estimatedHeight += 0.1
                }
            }
            let newSize = CGSize(width: estimatedWidth, height: estimatedHeight)
            imageView.frame.size = newSize
        } else {
            var estimatedWidth = willCropAreaRect.width
            var estimatedHeight : CGFloat {
                return estimatedWidth / imageStatus.ratio
            }
            if estimatedHeight < willCropAreaRect.height {
                while estimatedHeight < willCropAreaRect.height {
                    estimatedWidth += 0.1
                }
            }
            let newSize = CGSize(width: estimatedWidth, height: estimatedHeight)
            imageView.frame.size = newSize
        }
    }
    
    private func updateContentSize(_ updateFrameTo : Bool) {
        let imageSize = imageStatus.size
        let croppingAreaSize = croppingViewStates.size
        
        let topEdgeMarginX = (imageScrollView.frame.width - croppingAreaSize.width)
        let topEdgeMarginY = (imageScrollView.frame.height - croppingAreaSize.height)
        
        let estimateWidth = (imageSize.width + topEdgeMarginX)
        let estimateHeight = (imageSize.height + topEdgeMarginY)
        
        imageScrollView.contentSize = CGSize(width: estimateWidth, height: estimateHeight)
        
        var newOffSetX : CGFloat = 0
        var newOffSetY : CGFloat = 0
        
        let expectedOffSetX = (estimateWidth - imageScrollView.frame.width)/2
        let expectedOffSetY = (estimateHeight - imageScrollView.frame.height)/2
        
        if imageStatus.ratio > 1.1 {
            (expectedOffSetX >= 0) ? (newOffSetX = expectedOffSetX) : (newOffSetX = topEdgeMarginX)
            (expectedOffSetY >= 0) ? (newOffSetY = expectedOffSetY) : (newOffSetY = 0)
        } else if imageStatus.ratio < 0.9 {
            (expectedOffSetX >= 0) ? (newOffSetX = expectedOffSetX) : (newOffSetX = 0)
            (expectedOffSetY >= 0) ? (newOffSetY = expectedOffSetY) : (newOffSetY = topEdgeMarginY)
        } else {
            (expectedOffSetX >= 0) ? (newOffSetX = expectedOffSetX) : (newOffSetX = 0)
            (expectedOffSetY >= 0) ? (newOffSetY = expectedOffSetY) : (newOffSetY = 0)
        }
        
        if updateFrameTo {
            imageView.frame.origin = CGPoint(x: topEdgeMarginX/2, y: topEdgeMarginY/2)
            imageScrollView.setContentOffset(CGPoint(x: newOffSetX, y: newOffSetY), animated: false)
        }
    }
    
    private var estimateCropArea: CGRect {
        var factor : CGFloat = 0
        if imageStatus.ratio > croppingViewStates.ratio {
            factor = imageView.image!.size.height/croppingViewStates.size.height
        } else {
            factor = imageView.image!.size.width/croppingViewStates.size.width
        }
        let scale = 1/imageScrollView.zoomScale
        let x = imageScrollView.contentOffset.x * scale * factor
        let y = imageScrollView.contentOffset.y * scale * factor
        let width = croppingViewStates.size.width * scale * factor
        let height = croppingViewStates.size.height * scale * factor
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func performCrop() {
        let orientation = willCroppedImage.imageOrientation
        guard let croppedCGImage = willCroppedImage.cgImage?.cropping(to: estimateCropArea) else { print("image setting error"); return }
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: 1, orientation: orientation)
        imageScrollView.zoomScale = 1
        ImageCropDataManager.croppedImage = croppedImage
        requiredActionAfterCroppingFinished?()
    }
    
    // MARK: ImageCropData Manipulation
    
    struct CroppedImageData {
        var cropInformation: ImageCropInformation
        var imageData: Data
    }
    
    struct ImageCropInformation {
        var isHorizontal: Bool
        var percentageSizeOfWillCroppedArea: (width: Double, height: Double)
        var percentagePostionInScrollView: (dX: Double, dY: Double)
        var scaleInScrollView: Double
    }
    
    func generateImageCropInformation(scale: Double, imageRatio: Double, originalImageSize: CGSize, estimateCropAreaInImage: CGRect) -> ImageCropInformation {
        
        /*imageView.image!.size*/
        //        let percentageSizeWidth = Double((estimateCropArea.width/originalImageSizeFactor.width)*100)
        //        let percentageSizeHeight = Double((estimateCropArea.height/originalImageSizeFactor.height)*100)
        //        let percentageOriginX = Double((estimateCropArea.origin.x/originalImageSizeFactor.width)*100)
        //        let percentageOriginY = Double((estimateCropArea.origin.y/originalImageSizeFactor.height)*100)
        
        var isHorizontalImage: Bool {
            if imageRatio > 1 {
                return true
            } else {
                return false
            }
        }
        
        let originalImageSizeFactor = originalImageSize
        
        let percentageSizeWidth = Double((estimateCropAreaInImage.width/originalImageSizeFactor.width)*100)
        let percentageSizeHeight = Double((estimateCropAreaInImage.height/originalImageSizeFactor.height)*100)
        let percentageOriginX = Double((estimateCropAreaInImage.origin.x/originalImageSizeFactor.width)*100)
        let percentageOriginY = Double((estimateCropAreaInImage.origin.y/originalImageSizeFactor.height)*100)
        
        let cropInfo = ImageCropInformation(isHorizontal: isHorizontalImage, percentageSizeOfWillCroppedArea: (width: percentageSizeWidth, height: percentageSizeHeight), percentagePostionInScrollView: (dX: percentageOriginX, dY: percentageOriginY), scaleInScrollView: scale)
        
        return cropInfo
    }
    
    func quickReturnCropInfo() -> CroppedImageData? {
        guard let data = image else { return nil }
        let imageInfo = generateImageCropInformation(scale: Double(imageScrollView.zoomScale), imageRatio: Double(croppingViewStates.ratio), originalImageSize: imageView.image!.size, estimateCropAreaInImage: estimateCropArea)
        return CroppedImageData(cropInformation: imageInfo, imageData: data)
    }
    // End
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageScrollView.frame = fullFrame
        configureSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        configureSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        imageScrollView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        imageScrollView.delegate = self
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentSize(false)
    }
    
}

extension ImageCroppingView {
    
    private var fullFrame: CGRect {
        let width = self.frame.width
        let height = self.frame.height
        let size = CGSize(width: width, height: height)
        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    var centeredSuqareFrame: CGRect {
        let width = (fullFrame.width * 0.9).clearUnderDot
        let height = (fullFrame.height * 0.9).clearUnderDot
        let frameSize = CGSize(width: width, height: height)
        let origin = CGPoint(x: (imageScrollView.frame.width - width)/2, y: (imageScrollView.frame.height - height)/2)
        return CGRect(origin: origin, size: frameSize)
    }
    
    var verticalCenteredRectagleFrame: CGRect {
        let height = (imageScrollView.frame.height * 0.9).clearUnderDot
        let width = (height * 0.618).clearUnderDot
        let frameSize = CGSize(width: width, height: height)
        let origin = CGPoint(x: (imageScrollView.frame.width - width)/2, y: (imageScrollView.frame.height - height)/2)
        return CGRect(origin: origin, size: frameSize)
    }
    
    var horizontalCenteredRectangleFrame: CGRect {
        let width = (imageScrollView.frame.width * 0.9).clearUnderDot
        let height = (width * 0.618).clearUnderDot
        let frameSize = CGSize(width: width, height: height)
        let origin = CGPoint(x: (imageScrollView.frame.width - width)/2, y: (imageScrollView.frame.height - height)/2)
        return CGRect(origin: origin, size: frameSize)
    }
}
