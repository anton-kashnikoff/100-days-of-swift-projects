//
//  DetailViewController.swift
//  Project7
//
//  Created by Антон Кашников on 03.06.2023.
//

import UIKit
import WebKit

final class DetailViewController: UIViewController {
    // MARK: - Public Properties
    var detailItem: Petition?

    // MARK: - Private Properties
    private var webView: WKWebView!
    
    // MARK: - UIViewController
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem else {
            return
        }

        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: nil)
    }
}
