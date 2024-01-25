//
//  AppDelegate.swift
//  KYDigitScrollCounter
//
//  Created by Keyon on 2023/1/29.
//

import UIKit

public class ScrollableCounter: UIView {
    
    public enum ScrollDirection {
        case down
        case up
        var shift: Int {
            switch self {
            case .down:
                return 1
            case .up:
                return -1
            }
        }
    }
    
    // MARK: - Properties
    private let items: [UIView]
    public private(set) var currentIndex = 0
    private var currentItem: UIView {
        return items[currentIndex]
    }
    private var animator: UIViewPropertyAnimator?
    private var itemsBeingAnimated = [UIView]()
    var scrollDuration: TimeInterval = 0
    var animationCurve: AnimationCurve = .easeInOut
    var gradientView: UIView?
    static let noAnimationDuration: TimeInterval = 0.01
    
    // MARK: - Init
    init(items: [UIView], frame: CGRect = CGRect.zero, gradientColor: UIColor? = nil, gradientStop: Float? = nil) {
        assert(items.count > 0, "ScrollableCounter must be initialized with non empty array of items.")
        for item in items {
            assert(item.frame.equalTo(frame), "The frame of each item should equal the frame of the ScrollableCounter")
        }
        self.items = items
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(currentItem)
        currentItem.frame.origin = CGPoint.zero
        for (tag, item) in items.enumerated() {
            item.tag = tag
        }
        
        if let gradientColor = gradientColor, let gradientStop = gradientStop {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = frame
            gradientLayer.colors = [gradientColor.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, gradientColor.cgColor]
            gradientLayer.locations = [0, NSNumber(value: gradientStop), NSNumber(value: 1.0 - gradientStop), 1]
            let view = UIView(frame: frame)
            view.backgroundColor = .clear
            view.layer.addSublayer(gradientLayer)
            addSubview(view)
            bringSubviewToFront(view)
            gradientView = view
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Animation
    private func animateToItem(atIndex index: Int, direction: ScrollDirection, animated: Bool) {
        resetCurrentIndex(direction: direction)
        setupItemsToAnimate(atIndex: index, direction: direction)
        var animationDuration = scrollDuration
        if !animated {
            animationDuration = ScrollableCounter.noAnimationDuration
        }
        
        let animator = buildAnimations(direction: direction, duration: animationDuration)
        animator.addCompletion { position in
            self.animationCompletion(newCurrentIndex: index)
        }
        
        animator.startAnimation()
        self.animator = animator
    }
    
    private func animationCompletion(newCurrentIndex index: Int) {
        self.currentIndex = index
        for i in 0..<self.items.count {
            if i != index {
                self.items[i].removeFromSuperview()
            }
        }
        self.itemsBeingAnimated.removeAll()
    }
    
    private func buildAnimations(direction: ScrollDirection, duration: TimeInterval) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, curve: animationCurve, animations: nil)
        for (i, item) in itemsBeingAnimated.enumerated() {
            let diff = CGFloat(itemsBeingAnimated.count - (i + 1))
            animator.addAnimations {
                switch direction {
                case .down:
                    item.frame.origin = CGPoint(x: 0, y: diff * self.frame.height)
                case .up:
                    item.frame.origin = CGPoint(x: 0, y: diff * self.frame.height * -1)
                }
            }
        }
        return animator
    }
    
    func setupItemsToAnimate(atIndex index: Int, direction: ScrollDirection) {
        var offset: CGFloat = 0
        var itemIndex = currentIndex
        var distance = 0
        var continueBuilding = true
        while continueBuilding {
            let item = items[itemIndex]
            let isAlreadyBeingAnimated = itemsBeingAnimated.contains(item)
            if isAlreadyBeingAnimated {
                if distance == 0 {
                    offset = item.frame.origin.y
                }
            } else {
                addSubview(item)
            }
            
            switch direction {
            case .down:
                item.frame.origin = CGPoint(x: 0, y: frame.height * CGFloat(distance) * -1)
            case .up:
                item.frame.origin = CGPoint(x: 0, y: frame.height * CGFloat(distance))
            }
            item.frame.origin.y += offset
            
            if !isAlreadyBeingAnimated {
                itemsBeingAnimated.append(item)
            }
            
            if itemIndex == index {
                continueBuilding = false
            }
            distance += 1
            itemIndex = (itemIndex + direction.shift) % items.count
            if itemIndex < 0 {
                itemIndex = items.count - 1
            }
        }
        
        if let gradientView = gradientView {
            bringSubviewToFront(gradientView)
        }
    }
    
    // MARK: Control
    private func calculateDirection(toIndex index: Int) -> ScrollDirection {
        var direction: ScrollDirection
        var downDistance: Int
        var upDistance: Int
        
        if currentIndex == index {
            if currentItem.frame.minY > 0 {
                direction = .up
            } else {
                direction = .down
            }
        } else {
            if index > currentIndex {
                downDistance = index - currentIndex
            } else {
                downDistance = items.count - abs(currentIndex - index)
            }
            
            if index < currentIndex {
                upDistance = currentIndex - index
            } else {
                upDistance = items.count - abs(currentIndex - index)
            }
            
            if downDistance < upDistance {
                direction = .down
            } else if upDistance < downDistance {
                direction = .up
            } else {
                direction = .down
                if index < currentIndex {
                    direction = .up
                }
            }
        }
        
        return direction
    }
    
    private func removeDanglingItems() {
        for item in itemsBeingAnimated {
            if abs(item.frame.origin.y) >= frame.height {
                item.removeFromSuperview()
            }
        }
        
        itemsBeingAnimated.removeAll { item -> Bool in
            return item.superview == nil
        }
    }
    
    private func resetCurrentIndex(direction: ScrollDirection) {
        guard itemsBeingAnimated.count >= 2 else {
            if let onlyItem = itemsBeingAnimated.first {
                currentIndex = onlyItem.tag
            }
            return
        }
        let item0 = itemsBeingAnimated[0]
        let item1 = itemsBeingAnimated[1]
        
        switch direction {
        case .down:
            if item0.frame.minY > 0 {
                currentIndex = item0.tag
            } else {
                currentIndex = item1.tag
            }
        case .up:
            if item0.frame.minY < 0 {
                currentIndex = item0.tag
            } else {
                currentIndex = item1.tag
            }
        }
        
        if currentIndex == item0.tag {
            itemsBeingAnimated = [item0, item1]
        } else {
            itemsBeingAnimated = [item1, item0]
        }
        
    }
    
    func resetCurrentIndexToClosest() {
        guard itemsBeingAnimated.count >= 2 else {
            if let onlyItem = itemsBeingAnimated.first {
                currentIndex = onlyItem.tag
            }
            return
        }
        
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var minDistIndex: Int = 0
        var minDistance2: CGFloat = CGFloat.greatestFiniteMagnitude
        var minDistIndex2: Int = 0
        for (index, item) in itemsBeingAnimated.enumerated() {
            let distance = abs(item.frame.minY)
            if distance < minDistance {
                minDistance2 = minDistance
                minDistIndex2 = minDistIndex
                
                minDistance = distance
                minDistIndex = index
            } else if distance < minDistance2 {
                minDistance2 = distance
                minDistIndex2 = index
            }
        }
        
        currentIndex = itemsBeingAnimated[minDistIndex].tag
        let item0 = itemsBeingAnimated[minDistIndex]
        let item1 = itemsBeingAnimated[minDistIndex2]
        itemsBeingAnimated = [item0, item1]
    }
    
    public func scrollToItem(atIndex index: Int, animated: Bool = true) {
        stop()
        resetCurrentIndexToClosest()
        let direction = calculateDirection(toIndex: index)
    
        animateToItem(atIndex: index, direction: direction, animated: animated)
    }
    
    private func stop() {
        if let animator = animator {
            animator.stopAnimation(true)
        }
        removeDanglingItems()
    }
    
}
