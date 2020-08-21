
//  PreviewViewController.swift
//  SquirrelPreviewer
//
//  Created by Tony Smith on 08/11/2019.
//  Copyright © 2020 Tony Smith. All rights reserved.


import Cocoa
import Quartz
import Highlightr


class PreviewViewController: NSViewController, QLPreviewingController {
    
    // MARK:- Class Properties
    @IBOutlet var renderTextView: NSTextView!
    var fontName: String? = nil
    var fontIndex: Int = -1
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }
    

    // MARK:- View Lifecycle Functions

    override func viewWillAppear() {
        
        super.viewWillAppear()

        setFont()
    }
    

    func setFont() {
        // Get the font name preference
        //CFPreferencesAppSynchronize(("com.bps.Squinter" as CFString))
        if let suiteDefaults = UserDefaults.init(suiteName: "com.bps.suite.squinter") {
            suiteDefaults.synchronize()
            if let object = suiteDefaults.object(forKey: "com.bps.suite.squinter.fontNameIndex") {
                let indexData: NSNumber = object as! NSNumber
                let index: Int = indexData.intValue
                self.fontIndex = index
                switch(index) {
                    case 0:
                        self.fontName = "AndaleMono"
                    case 1:
                        self.fontName = "Courier"
                    case 2:
                        self.fontName = "Menlo-Regular"
                    case 3:
                        self.fontName = "Monaco"
                    case 4:
                        self.fontName = "SourceCodePro-Regular"
                    default:
                        self.fontName = "Menlo-Regular"
                }
            } else {
                self.fontIndex = -3
            }
        } else {
            self.fontName = "Menlo-Regular"
            self.fontIndex = -2
        }
    }


    // MARK:- QLPreviewingController Required Functions

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        // Load the source file using a co-ordinator as we don't know what thread this function
        // will be executed in when it's called by macOS' QuickLook code
        let fc: NSFileCoordinator = NSFileCoordinator()
        let intent: NSFileAccessIntent = NSFileAccessIntent.readingIntent(with: url)
        fc.coordinate(with: [intent], queue: .main) { (err) in
            if err == nil {
                // No error loading the file? Then continue
                do {
                    self.setFont()

                    // Read in the markdown from the specified file
                    let nutString: String = try String(contentsOf: intent.url, encoding: String.Encoding.utf8)
                    //nutString = "\(self.fontIndex)\n\(nutString)"

                    // Make an NSTextView to display the code
                    //let tv: NSTextView = NSTextView.init(frame: self.view.bounds)
                    
                    // Set the background generically, to support Dark Mode
                    //tv.backgroundColor = NSColor.textBackgroundColor

                    if let textViewStorage: NSTextStorage = self.renderTextView.textStorage {

                        if let highlightr = Highlightr() {
                            highlightr.setTheme(to: "qtcreator_dark")
                            let highlightedCode = highlightr.highlight(nutString, as: "squirrel")
                            textViewStorage.setAttributedString(highlightedCode!)
                        } else {
                            // Set the NSTextView's NSTextStorage font
                            var font: NSFont

                            if self.fontName != nil {
                                // Use the Squinter log font preference
                                font = NSFont.init(name: self.fontName!, size: 13.0) ?? NSFont.systemFont(ofSize: 13.0)
                            } else {
                                // Just use a generic (but guaranteed) font
                                font = NSFont.init(name: "SourceCodePro-Regular", size: 13.0) ?? NSFont.systemFont(ofSize: 13.0)
                            }

                            // Convert the program text into an NSAtrributedString for display...
                            let nas = NSAttributedString.init(string: nutString, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : NSColor.labelColor])

                            // ...and add the NSAtrributedString to the
                            textViewStorage.setAttributedString(nas)
                        }
                    }
                    
                    // Draw the NSTextView and its contents
                    //tv.display()
                    
                    // Create an NSScrollView, in which we'll embed the NSTextView
                    //let sv: NSScrollView = NSScrollView.init(frame: self.view.bounds)
                    //sv.hasVerticalScroller = true
                    //sv.borderType = NSBorderType.noBorder
                    //sv.documentView = tv
                    
                    // Finally add the NSScrollView to the primary view and apply constraints
                    // To keep the two the same size
                    //self.view.addSubview(sv)
                    //self.setViewConstraints(sv)
                    self.view.display()

                    // Hand control back to QuickLook
                    handler(nil)
                    return
                } catch {
                    // Do nothing, just fall through to the final line
                }
            }
            
            NSLog("Could not find file \(intent.url.lastPathComponent) to preview it")
            handler(err)
        }
    }
    
    
    func setViewConstraints(_ view: NSView) {

        // Programmatically apply constraints which bind the specified view to
        // the edges of the view controller's primary view

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
}
