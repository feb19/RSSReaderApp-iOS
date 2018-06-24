//
//  ViewController.swift
//  RSSReaderApp
//
//  Created by TakahashiNobuhiro on 2018/06/24.
//  Copyright © 2018 feb19. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UITableViewController, XMLParserDelegate {
    
    //http://menthas.com/ios/rss
    let feedUrl = URL(string: "https://news.yahoo.co.jp/pickup/rss.xml")!
    var feedItems = [FeedItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let parser: XMLParser! = XMLParser(contentsOf: feedUrl)
        parser.delegate = self
        parser.parse()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    // MARK: -
    // MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        let feedItem = feedItems[indexPath.row]
        cell.textLabel?.text = feedItem.title
        
        let d = feedItem.pubDate
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy/MM/dd HH:mm"
        cell.detailTextLabel?.text = df.string(from: d!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedItem = feedItems[indexPath.row]
//        UIApplication.shared.open(URL(string: feedItem.url)!, options: [:], completionHandler: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = SFSafariViewController(url: URL(string: feedItem.url)!)
        vc.delegate = self as SFSafariViewControllerDelegate
        navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    
    // MARK: -
    // MARK: XMLParser
    
    var currentElementName : String!
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElementName = nil
        if elementName == "item" {
            feedItems.append(FeedItem())
        } else {
            currentElementName = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if feedItems.count > 0 {
//            print("\(string)")
            let lastItem = feedItems[feedItems.count - 1]
            switch currentElementName {
            case "title":
                let tmpString = lastItem.title
                lastItem.title = (tmpString != nil) ? tmpString! + string : string
            case "link":
                lastItem.url = string
            case "pubDate":
                let df = DateFormatter()
                df.locale = Locale(identifier: "en_US_POSIX")
                // http://nsdateformatter.com
                df.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                df.timeZone = TimeZone(secondsFromGMT: 0)
                let d = df.date(from: string)
                lastItem.pubDate = d!
            case "enclosure":
                lastItem.enclosure = string
            case "media:thumbnail":
                lastItem.thumbnail = string
            case "description":
                lastItem.description = string
            default: break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElementName = nil
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        tableView.reloadData()
    }
}

extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
