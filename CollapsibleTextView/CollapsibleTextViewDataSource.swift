//
//  CollapsibleTextViewDataSource.swift
//  CollapsibleTextView
//
//  Created by Matthew Palmer on 6/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol CollapsibleTextViewDataSourceForRegionViewDelegate: class {
    func collapsibleTextViewDataSource(dataSource: CollapsibleTextViewDataSourceForRegionView, didChangeRegionAtIndex index: Int)
}

private class CollapsedRegionView: UIView {
    lazy var expandIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .yellowColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(expandIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func intrinsicContentSize() -> CGSize {
        return expandIndicator.frame.size
    }
}

private class ExpandedRegionView: UIView {
    lazy var collapseIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .orangeColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.userInteractionEnabled = false
        textView.scrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .whiteColor()
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(textView)
        self.addSubview(collapseIndicator)
        
        setupTextViewConstraints()
        setupCollapseIndicatorConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override func updateConstraints() {
        super.updateConstraints()
    }
    
    private override func intrinsicContentSize() -> CGSize {
        let width = textView.intrinsicContentSize().width + collapseIndicator.frame.width
        let height = textView.intrinsicContentSize().height + collapseIndicator.frame.height
        return CGSize(width: width, height: height)
    }
    
    private func setupTextViewConstraints() {
        let top = NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 10)
        
        addConstraints([top, left, right, height])
    }
    
    private func setupCollapseIndicatorConstraints() {
        let top = NSLayoutConstraint(item: collapseIndicator, attribute: .Top, relatedBy: .Equal, toItem: textView, attribute: .Bottom, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: collapseIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: collapseIndicator, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
        let width = NSLayoutConstraint(item: collapseIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 50)
        let height = NSLayoutConstraint(item: collapseIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 44)
        
        addConstraints([top, bottom, left, width, height])
    }
}

class CollapsibleTextViewDataSourceForRegionView: NSObject, RegionViewDataSource {
    private enum State {
        case Expanded, Collapsed, Static
    }
    
    private struct Region {
        var state: State
        var range: NSRange
    }
    
    private var regions: [Region] = []
    private var textString: String = ""
    
    weak var delegate: CollapsibleTextViewDataSourceForRegionViewDelegate?
    
    init(text: String, initiallyCollapsedRegions: [NSRange]) {
        self.textString = text
        super.init()
        setRegions(initiallyCollapsedRegions)
    }
    
    func numberOfRegionsInRegionView(regionView: RegionView) -> Int {
        return regions.count
    }
    
    func regionView(regionView: RegionView, viewForRegionAtIndex index: Int) -> UIView {
        let region = regions[index]
        
        if region.state == .Collapsed {
            return collapsedRegionForIndex(index)
        } else if region.state == .Expanded {
            return expandedRegionForIndex(index)
        } else {
            return staticRegionForIndex(index)
        }
    }
    
    private func staticRegionForIndex(index: Int) -> UIView {
        let view = UITextView()
        view.userInteractionEnabled = false
        view.scrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = textForRegion(regions[index])
        return view
    }
    
    private func expandedRegionForIndex(index: Int) -> UIView {
        let view = ExpandedRegionView()
        
        view.textView.text = textForRegion(regions[index])
        
        view.collapseIndicator.tag = index
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapRegion:")
        view.collapseIndicator.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    private func collapsedRegionForIndex(index: Int) -> UIView {
        let view = CollapsedRegionView()

        view.translatesAutoresizingMaskIntoConstraints = false

        view.expandIndicator.tag = index
        let tapGesture = UITapGestureRecognizer(target: self, action: "didTapRegion:")
        view.expandIndicator.addGestureRecognizer(tapGesture)
        return view
    }
    
    func didTapRegion(gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        toggleRegionAtIndex(index)
        delegate?.collapsibleTextViewDataSource(self, didChangeRegionAtIndex: index)
    }
    
    private func textForRegion(region: Region) -> String {
        return (textString as NSString).substringWithRange(region.range)
    }
    
    private func toggleRegionAtIndex(index: Int) {
        let region = regions[index]
        
        if region.state == .Collapsed {
            // expand
            regions[index].state = .Expanded
        } else if region.state == .Expanded {
            // collapse
            regions[index].state = .Collapsed
        }
    }
    
    // Should only be called from init
    private func setRegions(collapsed: [NSRange]) {
        let text = textString
        let collapsedRegions = collapsed
        
        if collapsedRegions.count == 0 {
            regions.append(Region(state: .Static, range: NSMakeRange(0, text.characters.count)))
        }
        
        var lastCollapsedRegion: Region!
        
        for index in collapsedRegions.startIndex..<collapsedRegions.endIndex {
            // First region
            if index == collapsedRegions.startIndex {
                let range = NSMakeRange(0, collapsedRegions[index].location)
                if range.length != 0 {
                    regions.append(Region(state: .Static, range: range))
                }
                
                let c = Region(state: .Collapsed, range: collapsedRegions[index])
                regions.append(c)
                lastCollapsedRegion = c
                continue
            }
            
            // Last region
            if index == collapsedRegions.endIndex - 1 {
                let penultimateStaticLocation = lastCollapsedRegion.range.location + lastCollapsedRegion.range.length
                let penultimateStaticLength = collapsedRegions[index].location - penultimateStaticLocation
                let penultimateStaticRange = NSMakeRange(penultimateStaticLocation, penultimateStaticLength)
                if penultimateStaticLocation != 0 {
                    regions.append(Region(state: .Static, range: penultimateStaticRange))
                }
                
                let c = Region(state: .Collapsed, range: collapsedRegions[index])
                regions.append(c)
                lastCollapsedRegion = c
                
                let lastRegion = regions.last!
                let endOfLastRegion = regions.last!.range.location + lastRegion.range.length
                let range = NSMakeRange(endOfLastRegion, text.characters.count - endOfLastRegion)
                
                if range.length != 0 {
                    regions.append(Region(state: .Static, range: range))
                }
                continue
            }
            
            // Middle regions
            
            // Range for the text between the last collapsed region and the beginning of the new collapsed region.
            let location = lastCollapsedRegion.range.location + lastCollapsedRegion.range.length
            let length = collapsedRegions[index].location - location
            let range = NSMakeRange(location, length)
            
            if range.length != 0 {
                regions.append(Region(state: .Static, range: range))
            }
            
            let c = Region(state: .Collapsed, range: collapsedRegions[index])
            regions.append(c)
            lastCollapsedRegion = c
        }
    }

}
