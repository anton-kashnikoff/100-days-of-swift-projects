//
//  WebViewController.swift
//  Project4
//
//  Created by Антон Кашников on 23.05.2023.
//

import WebKit

final class WebViewController: UIViewController {
    // MARK: - Private Properties
    private var webView: WKWebView!
    private var progressView: UIProgressView!

    // MARK: - Public Properties
    var availableWebsites = ["kodeco.com", "hackingwithswift.com"]
    var selectedWebSite: String?

    // MARK: - UIViewController
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()

        fillAndShowToolbar()

        let url = URL(string: "https://" + (selectedWebSite ?? ""))!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    // MARK: - NSObject
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    // MARK: - Private Methods
    @objc private func openTapped() {
        let alertController = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        
        for website in availableWebsites {
            alertController.addAction(UIAlertAction(title: website, style: .default, handler: openPage(action:)))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        webView.load(URLRequest(url: url))
    }
    
    private func fillAndShowToolbar() {
        let goBackButton = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
        let goForwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        toolbarItems = [goBackButton, goForwardButton, progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if #available(iOS 16.0, *) {
            if let host = navigationAction.request.url?.host() {
                for website in availableWebsites {
                    if host.contains(website) {
                        decisionHandler(.allow)
                        return
                    }
                }
            }
        } else {
            if let host = navigationAction.request.url?.host {
                for website in availableWebsites {
                    if host.contains(website) {
                        decisionHandler(.allow)
                        return
                    }
                }
            }
        }

        let alertController = UIAlertController(title: "Oops!", message: "Sorry, you can't go there", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)

        decisionHandler(.cancel)
    }
}
