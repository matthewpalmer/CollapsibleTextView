//
//  CollapsibleTextView.swift
//  CollapsibleTextView
//
//  Created by Matthew Palmer on 5/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

public typealias CollapsedRegion = NSRange

public protocol CollapsibleTextViewDataSource: class {
    /// The full text string for the text view, including parts that will be collapsed.
    func collapsibleTextViewTextString(textView: CollapsibleTextView) -> String
    
    /// Non-overlapping ordered list of text regions that should be replaced with the specified view.
    func collapsibleTextViewInitiallyCollapsedRegions(textView: CollapsibleTextView) -> [CollapsedRegion]
    
    /// The view that the user can tap to expand the collapsed section
    func collapsibleTextViewExpandIndicator() -> UIView
    
    /// The view that the user can tap to collapse the expanded section
    func collapsibleTextViewCollapseIndicator() -> UIView
    
    /// Return a text view in which we can render the text content. This is provided so that a UITextView subclass can be used if desired. If unimplement, a regular UITextView is used.
    ///
    /// Note that we mess with this text view a fair bit (for AutoLayout, disabling scrolling, disabling editing, and a bunch more).
    func collapsibleTextViewContentTextView(textView: CollapsibleTextView, withString string: String, isExpandedRegion: Bool) -> UITextView
}

extension CollapsibleTextViewDataSource {
    func collapsibleTextViewContentTextView(textView: CollapsibleTextView, withString string: String, isExpandedRegion: Bool) -> UITextView {
        let textView = UITextView()
        textView.text = string
        return textView
    }
}

public protocol CollapsibleTextViewDelegate {}

private class StaticTableViewCell: UITableViewCell {
    var contentTextView: UITextView = UITextView() {
        didSet {
            oldValue.removeFromSuperview()
            contentTextView.translatesAutoresizingMaskIntoConstraints = false
            contentTextView.scrollEnabled = false
            contentTextView.userInteractionEnabled = false
            contentView.addSubview(contentTextView)
            contentView.addConstraints(textViewConstraints())
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.userInteractionEnabled = false
        contentTextView.scrollEnabled = false
        contentView.addSubview(contentTextView)
        
        contentView.addConstraints(textViewConstraints())
    }
    
    private func textViewConstraints() -> [NSLayoutConstraint] {
        let left = NSLayoutConstraint(item: contentTextView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: contentTextView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: contentTextView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: contentTextView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: contentTextView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        return [top, height, left, right, bottom]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class CollapsedTableViewCell: UITableViewCell {
    var collapseIndicator: UIView = UIView() {
        didSet {
            oldValue.removeFromSuperview()
            contentView.addSubview(collapseIndicator)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ExpandedTableViewCell: UITableViewCell {
    var collapseIndicator: UIView = UIView() {
        didSet {
            oldValue.removeFromSuperview()
            collapseIndicator.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(collapseIndicator)
            contentView.addConstraints(collapseIndicatorConstraints())
        }
    }
    
    var contentTextView: UITextView = UITextView() {
        didSet {
            oldValue.removeFromSuperview()
            contentTextView.translatesAutoresizingMaskIntoConstraints = false
            contentTextView.scrollEnabled = false
            contentTextView.userInteractionEnabled = false
            contentView.addSubview(contentTextView)
            contentView.addConstraints(textViewConstraints())
            contentView.addConstraints(collapseIndicatorAndTextViewRelationshipConstraints())
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        translatesAutoresizingMaskIntoConstraints = false
        collapseIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentTextView.scrollEnabled = false
        contentTextView.userInteractionEnabled = false
        
        doConstraints()
    }
    
    private func doConstraints() {
        contentView.addSubview(collapseIndicator)
        contentView.addSubview(contentTextView)
        
        contentView.addConstraints(textViewConstraints())
        contentView.addConstraints(collapseIndicatorConstraints())
        contentView.addConstraints(collapseIndicatorAndTextViewRelationshipConstraints())
    }
    
    private func textViewConstraints() -> [NSLayoutConstraint] {
        let left = NSLayoutConstraint(item: contentTextView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: contentTextView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: contentTextView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let height = NSLayoutConstraint(item: contentTextView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 0.0)

        return [top, height, left, right]
    }
    
    private func collapseIndicatorAndTextViewRelationshipConstraints() -> [NSLayoutConstraint] {
        return [NSLayoutConstraint(item: collapseIndicator, attribute: .Top, relatedBy: .Equal, toItem: contentTextView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)]
    }
    
    private func collapseIndicatorConstraints() -> [NSLayoutConstraint] {
        let bottom = NSLayoutConstraint(item: collapseIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        let size = collapseIndicator.frame.size
        let heightConstant = size.height >= 0 ? size.height : 0
        let widthConstant = size.width >= 0 ? size.width : 0
        let height = NSLayoutConstraint(item: collapseIndicator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: heightConstant)
        let width = NSLayoutConstraint(item: collapseIndicator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: widthConstant)
        return [bottom, height, width]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class CollapsibleTextView: UIView, UITableViewDataSource, UITableViewDelegate {
    private enum State {
        case Expanded, NotExpanded, Static
    }
    
    private struct Region {
        var state: State
        var range: NSRange
    }
    
    private var regions: [Region] = []
    private var textString: String = ""
    
    public unowned var dataSource: CollapsibleTextViewDataSource
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    
    private let collapsedReuseIdentifier = "collapsedCell"
    private let expandedReuseIdentifier = "expandedCell"
    private let staticReuseIdentifier = "staticCell"
    
    public init(dataSource: CollapsibleTextViewDataSource) {
        self.dataSource = dataSource
        super.init(frame: CGRectZero)
        self.textString = dataSource.collapsibleTextViewTextString(self)
        addSubview(tableView)
        setInitialConstraints()
        setRegions()
        self.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(ExpandedTableViewCell.self, forCellReuseIdentifier: expandedReuseIdentifier)
        tableView.registerClass(CollapsedTableViewCell.self, forCellReuseIdentifier: collapsedReuseIdentifier)
        tableView.registerClass(StaticTableViewCell.self, forCellReuseIdentifier: staticReuseIdentifier)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let region = regions[indexPath.row]
        
        guard region.state != .NotExpanded else {
            let cell = tableView.dequeueReusableCellWithIdentifier(collapsedReuseIdentifier, forIndexPath: indexPath) as! CollapsedTableViewCell
        
            cell.collapseIndicator = dataSource.collapsibleTextViewExpandIndicator()
            cell.collapseIndicator.tag = indexPath.row
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "didTapExpandIndicator:")
            cell.collapseIndicator.addGestureRecognizer(tapGesture)
            
            return cell
        }
        
        guard region.state != .Expanded else {
            let cell = tableView.dequeueReusableCellWithIdentifier(expandedReuseIdentifier, forIndexPath: indexPath) as! ExpandedTableViewCell
            cell.collapseIndicator = dataSource.collapsibleTextViewCollapseIndicator()
            cell.contentTextView = dataSource.collapsibleTextViewContentTextView(self, withString: textForRegion(region), isExpandedRegion: true)
            cell.tag = indexPath.row
            let tapGesture = UITapGestureRecognizer(target: self, action: "didTapCollapseIndicator:")
            cell.addGestureRecognizer(tapGesture)
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(staticReuseIdentifier, forIndexPath: indexPath) as! StaticTableViewCell
        cell.contentTextView = dataSource.collapsibleTextViewContentTextView(self, withString: textForRegion(region), isExpandedRegion: false)
        return cell
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    internal func didTapCollapseIndicator(recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view else { return }
        toggleRegionAtIndex(view.tag)
        tableView.reloadData()
    }
    
    internal func didTapExpandIndicator(recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view else { return }
        toggleRegionAtIndex(view.tag)
        // Reloading rows for just this index path fucks the scroll position
        tableView.reloadData()
    }
    
    private func toggleRegionAtIndex(index: Int) {
        let region = regions[index]
        
        if region.state == .NotExpanded {
            // expand
            regions[index].state = .Expanded
        } else if region.state == .Expanded {
            // collapse
            regions[index].state = .NotExpanded
        }
    }

    private func textForRegion(region: Region) -> String {
        return (textString as NSString).substringWithRange(region.range)
    }
    
    private func addGestureHandler() {
        
    }
    
    private func setInitialConstraints() {
        let left = NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        addConstraints([left, right, top, bottom])
    }
    
    // Should only be called from init
    private func setRegions() {
        let text = dataSource.collapsibleTextViewTextString(self)
        let collapsedRegions = dataSource.collapsibleTextViewInitiallyCollapsedRegions(self)
        
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
                
                let c = Region(state: .NotExpanded, range: collapsedRegions[index])
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
                
                let c = Region(state: .NotExpanded, range: collapsedRegions[index])
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
            
            let c = Region(state: .NotExpanded, range: collapsedRegions[index])
            regions.append(c)
            lastCollapsedRegion = c
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
