//
//  AppDelegate.swift
//  KYDigitScrollCounter
//
//  Created by Keyon on 2023/1/29.
//

import UIKit

public class NumberScrollCounter: UIView {
    
    // MARK: - Parameters
    
    private var digitScrollers = [KYDigitScrollCounter]()
    
    private var fadeOutDuration: TimeInterval {
        return slideDuration / 2
    }
    public var scrollDuration: TimeInterval
    public var slideDuration: TimeInterval = 0.5
    public private(set) var currentValue: String
    public var seperatorSpacing: CGFloat
    public let font: UIFont
    public let textColor: UIColor
    private let digitScrollerBackgroundColor: UIColor = .clear
    public var prefix: String?
    public var suffix: String?
    let seperator: String
    let negativeSign = "-"
    
    private var prefixView: UIView?
    private var suffixView: UIView?
    private var seperatorView: UIView?
    private var negativeSignView: UIView?
    private var seperatorLocation: Int?
    
    private let gradientColor: UIColor?
    private let gradientStop: Float?
    
    private var animator: UIViewPropertyAnimator?
    
    var animationCurve: AnimationCurve = .easeInOut
    
    private var startingXCoordinate: CGFloat {
        var startingX: CGFloat = 0
        if let prefixView = prefixView {
            startingX += prefixView.frame.width
        }
        if let negativeSignView = negativeSignView, currentValue.toDouble() < 0 {
            startingX += negativeSignView.frame.width
        }
        return startingX
    }

    public override var intrinsicContentSize: CGSize {
        .init(
            width: suffixView?.frame.maxX ?? digitScrollers.last?.frame.maxX ?? frame.width,
            height: digitScrollers.first?.frame.height ?? frame.height
        )
    }
    
    // MARK: - Init
    public init(value: String,
                scrollDuration: TimeInterval = 0.3,
                prefix: String? = nil,
                suffix: String? = nil,
                seperator: String = ".",
                seperatorSpacing: CGFloat = 0,
                font: UIFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize),
                textColor: UIColor = .black,
                animateInitialValue: Bool = false,
                gradientColor: UIColor? = nil,
                gradientStop: Float? = nil) {

        self.currentValue = value
        
        self.font = font
        self.textColor = textColor
        
        self.prefix = prefix
        self.suffix = suffix
        self.seperator = seperator
        self.seperatorSpacing = seperatorSpacing
        
        self.scrollDuration = scrollDuration
        self.gradientColor = gradientColor
        if let stoppingPoint = gradientStop, stoppingPoint < 0.5 {
            self.gradientStop = gradientStop
        } else {
            self.gradientStop = nil
        }
        
        super.init(frame: CGRect.zero)
        
        setValue(value, animated: animateInitialValue)
        frame.size.height = digitScrollers.first!.frame.height
        
        sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeToFit() {
        var width: CGFloat = 0
        
        if let suffixView = suffixView {
            width = suffixView.frame.origin.x + suffixView.frame.width
        } else if let lastDigit = digitScrollers.last {
            width = lastDigit.frame.origin.x + lastDigit.frame.width
        }
        
        self.frame.size.width = width
    }
    
    // MARK: - Control
    public func setValue(_ value: String, animated: Bool = true) {
        currentValue = value
        
        let digitString = getStringArray(fromValue: value)
        
        seperatorLocation = digitString.firstIndex(of: seperator)
        
        var digitsOnly = [Int]()
        for entry in digitString {
            if let value = Int(entry) {
                digitsOnly.append(value)
            }
        }
     
        if digitsOnly.count > digitScrollers.count {
            let digitsToAdd = digitsOnly.count - digitScrollers.count
            updateScrollers(add: digitsToAdd)
        } else if digitScrollers.count > digitsOnly.count {
            let digitsToRemove = digitScrollers.count - digitsOnly.count
            updateScrollers(remove: digitsToRemove, animated: animated)
        }
        
        updateScrollers(withDigits: digitsOnly, animated: animated)
        updateScrollerLayout(animated: animated)
    }
    
    private func getStringArray(fromValue value: String) -> [String] {
        return value.compactMap { character -> String in
            var entry = String(character)
            let result = character.wholeNumberValue
            if let resultNumber = result {
                entry = "\(resultNumber)"
            }
            return entry
        }
    }
        
    
    // MARK: - Scroller Updates
    private func updateScrollerLayout(animated: Bool) {
        if let animator = self.animator {
            animator.stopAnimation(true)
        }
        
        var animationDuration = slideDuration
        if !animated {
            animationDuration = ScrollableCounter.noAnimationDuration
        }
        animator = UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve, animations: nil)
        
        updateNegativeSign()
        updatePrefix()
        createSeperatorViewIfNeeded()
        updateDigitScrollersLayout()
        updateSuffix()
        
        animator!.addCompletion({ _ in
            self.animator = nil
        })

        invalidateIntrinsicContentSize()
        animator?.addAnimations { [weak self] in
            self?.superview?.layoutIfNeeded()
        }
        animator!.startAnimation()
    }
    
    private func createSeperatorViewIfNeeded() {
        guard seperatorView == nil else {
            return
        }
        
        let seperatorLabel = UILabel()
        seperatorLabel.text = seperator
        seperatorLabel.textColor = textColor
        seperatorLabel.font = font
        seperatorLabel.sizeToFit()
        seperatorLabel.frame.size.width += 2 * seperatorSpacing
        seperatorLabel.textAlignment = .center
        seperatorLabel.frame.origin = CGPoint.zero
        addSubview(seperatorLabel)
        
        seperatorLabel.alpha = 0
        seperatorView = seperatorLabel
    }
    
    private func updateDigitScrollersLayout() {
        guard let animator = self.animator else {
            return
        }
        
        let startingX = startingXCoordinate
        
        for (index, scroller) in digitScrollers.enumerated() {
            if scroller.superview == nil {
                addSubview(scroller)
                scroller.frame.origin.x = startingX
                scroller.alpha = 0
            }
            
            var x = startingX + CGFloat(index) * scroller.frame.width
            if let seperatorLocation = seperatorLocation, index >= seperatorLocation, let seperatorView = seperatorView {
                x += seperatorView.frame.width
            }
            animator.addAnimations {
                scroller.alpha = 1
                scroller.frame.origin.x = x
            }
            
            if index == seperatorLocation, let seperatorView = seperatorView {
                animator.addAnimations {
                    seperatorView.alpha = 1
                    seperatorView.frame.origin.x = (startingX + CGFloat(index) * scroller.frame.width)
                }
            }
        }
    }
    
    private func updateNegativeSign() {
        guard let animator = self.animator else {
            return
        }
        
        let includeNegativeSign = currentValue.toDouble() < 0
        
        if includeNegativeSign {
            if let negativeSignView = negativeSignView, negativeSignView.alpha != 1 {
                animator.addAnimations {
                    negativeSignView.alpha = 1
                }
            } else if negativeSignView == nil {
                let negativeLabel = UILabel()
                negativeLabel.text = negativeSign
                negativeLabel.textColor = textColor
                negativeLabel.font = font
                negativeLabel.sizeToFit()
                negativeLabel.frame.origin = CGPoint.zero
                addSubview(negativeLabel)
                
                negativeLabel.alpha = 0
                negativeSignView = negativeLabel
                animator.addAnimations {
                    negativeLabel.alpha = 1
                }
            }
        } else {
            if let negativeSignView = negativeSignView {
                animator.addAnimations {
                    negativeSignView.alpha = 0
                }
                animator.addCompletion { _ in
                    negativeSignView.removeFromSuperview()
                    self.negativeSignView = nil
                }
            }
        }
    }
    
    func updatePrefix() {
        guard let animator = self.animator else {
            return
        }
        
        let includeNegativeSign = currentValue.toDouble() < 0
        
        if prefixView == nil, let prefix = prefix {
            let prefixLabel = UILabel()
            prefixLabel.text = prefix
            prefixLabel.textColor = textColor
            prefixLabel.font = font
            prefixLabel.sizeToFit()
            prefixLabel.frame.origin = CGPoint.zero
            addSubview(prefixLabel)

            prefixLabel.alpha = 0
            prefixView = prefixLabel
        }

        if let prefixView = self.prefixView {
            var prefixX: CGFloat = 0
            if let negativeSignView = negativeSignView, includeNegativeSign {
                prefixX = negativeSignView.frame.width
            }
            animator.addAnimations {
                prefixView.frame.origin.x = prefixX
                prefixView.alpha = 1
            }
        }
    }
    
    func updateSuffix() {
        guard let animator = self.animator else {
            return
        }
        
        if suffixView == nil, let suffix = suffix {
            let suffixLabel = UILabel()
            suffixLabel.text = suffix
            suffixLabel.textColor = textColor
            suffixLabel.font = font
            suffixLabel.sizeToFit()
            suffixLabel.frame.origin = CGPoint.zero
            addSubview(suffixLabel)

            suffixLabel.alpha = 0
            suffixView = suffixLabel
        }

        if let suffixView = self.suffixView, let scroller = digitScrollers.first {
            var suffixX: CGFloat = 0
            suffixX += scroller.frame.width * CGFloat(digitScrollers.count)
            if let view = seperatorView {
                suffixX += view.frame.width
            }
            if let view = prefixView {
                suffixX += view.frame.width
            }
            if let view = negativeSignView, currentValue.toDouble() < 0 {
                suffixX += view.frame.width
            }
            
            animator.addAnimations {
                suffixView.frame.origin.x = suffixX
                suffixView.alpha = 1
            }
        }
    }
    
    private func updateScrollers(add count: Int) {
        var newScrollers = [KYDigitScrollCounter]()
        for _ in 0..<count {
            let digitScrollCounter = KYDigitScrollCounter(font: font, textColor: textColor, backgroundColor: digitScrollerBackgroundColor, scrollDuration: scrollDuration, gradientColor: gradientColor, gradientStop: gradientStop)
            newScrollers.append(digitScrollCounter)
        }
        digitScrollers.insert(contentsOf: newScrollers, at: 0)
    }
    
    private func updateScrollers(remove count: Int, animated: Bool) {
        var animationDuration = fadeOutDuration
        if !animated {
            animationDuration = ScrollableCounter.noAnimationDuration
        }
        for index in 0..<count {
            let scroller = digitScrollers[0]
            let leftShift = CGFloat(index) * scroller.frame.width * -1
            
            digitScrollers.remove(at: 0)
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                scroller.alpha = 0
                scroller.frame.origin.x += leftShift
            }) { _ in
                scroller.removeFromSuperview()
            }
        }
    }
    
    private func updateScrollers(withDigits digits: [Int], animated: Bool) {
        if digits.count == digitScrollers.count {
            for (i, scroller) in digitScrollers.enumerated() {
                scroller.scrollToItem(atIndex: digits[i], animated: animated)
            }
        }
    }
}
