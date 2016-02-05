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
        
        let view = UITextView()
        view.scrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if region.state == .Collapsed {
            view.text = ">>>"
            view.backgroundColor = UIColor.groupTableViewBackgroundColor()
            view.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: "didTapRegion:")
            view.addGestureRecognizer(tapGesture)
        } else {
            view.text = textForRegion(region)
            view.backgroundColor = UIColor(hue: CGFloat(0.1) * CGFloat(index), saturation: 1.0, brightness: 0.8, alpha: 1.0)
        }
        
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
