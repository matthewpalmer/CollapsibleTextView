//
//  ViewController.swift
//  CollapsibleTextView
//
//  Created by Matthew Palmer on 5/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CollapsibleTextViewDataSource {
    lazy var collapsibleTextView: CollapsibleTextView = {
        let c = CollapsibleTextView(dataSource: self)
        return c
    }()
    
    func collapsibleTextViewTextString(textView: CollapsibleTextView) -> String {
        let file = NSBundle.mainBundle().URLForResource("Email-HTML", withExtension: nil)
        let data = NSData(contentsOfURL: file!)
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print(string?.length)
        return string! as String
    }
    
    func collapsibleTextViewExpandIndicator() -> UIView {
        let view = UIView(frame: CGRect(x: 40, y: 0, width: 40, height: 40))
        view.backgroundColor = .blueColor()
        return view
    }
    
    func collapsibleTextViewCollapseIndicator() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 70))
        view.backgroundColor = .redColor()
        return view
    }
    
    func collapsibleTextViewInitiallyCollapsedRegions(textView: CollapsibleTextView) -> [CollapsedRegion] {
        return [
//            NSMakeRange(1000, 190),
        ]
    }
    
    func collapsibleTextViewContentTextView(textView: CollapsibleTextView, withString string: String, isExpandedRegion: Bool) -> UITextView {
        let textView = UITextView()
//        
//        NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
//        
//        NSAttributedString *preview = [[NSAttributedString alloc] initWithData:[_html dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:&error];
        let options = [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType ]
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
        let html = try! NSAttributedString(data: data, options: options, documentAttributes: nil)
        
        textView.backgroundColor = isExpandedRegion ? .yellowColor() : .greenColor()
        textView.attributedText = html
        return textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        view.addSubview(collapsibleTextView)
        collapsibleTextView.backgroundColor = .redColor()
        
        let height = NSLayoutConstraint(item: collapsibleTextView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1.0, constant: 0)
        let width = NSLayoutConstraint(item: collapsibleTextView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: 0)
        let leading = NSLayoutConstraint(item: collapsibleTextView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: collapsibleTextView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0)

        view.addConstraints([height, width, leading, top])
        
        print("Done view did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

