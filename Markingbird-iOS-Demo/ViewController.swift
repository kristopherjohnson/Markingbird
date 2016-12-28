//
//  ViewController.swift
//  Copyright © 2016 Kristopher Johnson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Properties

    // Internal

    var markdown: Markdown?

    // IBOutlets 

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var webView: UIWebView!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        textView.keyboardDismissMode = .interactive

        var options = MarkdownOptions()

        options.autoHyperlink = true
        options.autoNewlines = true
        options.emptyElementSuffix = ">"
        options.encodeProblemUrlCharacters = true
        options.linkEmails = true
        options.strictBoldItalic = true

        markdown = Markdown(options: options)
    }

    // MARK: Actions

    @IBAction func dismissKeyboard(sender: AnyObject) {
        textView.resignFirstResponder()
    }
}

extension ViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {

        if let markdownToHTML = markdown?.transform(textView.text) {

            webView.loadHTMLString(markdownToHTML, baseURL: nil)
        }
    }
}
