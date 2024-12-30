//
//  WebViewController.swift
//  Project16
//
//  Created by Антон Кашников on 17/12/2023.
//

import WebKit

final class WebViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var webView: WKWebView!
    
    // MARK: - Public Properties
    var capital: String?
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let capital, let url = URL(string: "https://en.wikipedia.org/wiki/\(capital)") else { return }

        webView.load(URLRequest(url: url))
    }
}
