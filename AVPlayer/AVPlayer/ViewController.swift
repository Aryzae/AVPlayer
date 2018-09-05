//
//  ViewController.swift
//  AVPlayer
//
//  Created by aryzae on 2018/09/05.
//  Copyright © 2018年 aryzae. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var avPlayerLayer: AVPlayerLayer!
    var avPlayer: AVPlayer!

    // video idから再生url取れる 参考url -> https://muunyblue.github.io/0a7d83f084ec258aefd128569dda03d7.html
    // https://www.youtube.com/get_video_info?video_id=<video_id>
    // https://www.youtube.com/embed/R9780hhdDPk の `R9780hhdDPk`がvideo_id
    // https://www.youtube.com/embed/dLWOKfcns08
    // https://www.youtube.com/embed/ZnfHNU6iej4
    // https://www.youtube.com/embed/fHsQ-f7-nmE

    let youtubeUrls = ["https://www.youtube.com/get_video_info?video_id=R9780hhdDPk",
                       "https://www.youtube.com/get_video_info?video_id=dLWOKfcns08",
                       "https://www.youtube.com/get_video_info?video_id=ZnfHNU6iej4",
                       "https://www.youtube.com/get_video_info?video_id=fHsQ-f7-nmE"]
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avPlayer = AVPlayer(playerItem: nil)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.frame
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layer.addSublayer(avPlayerLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getURL(_ url: String, completion: @escaping (_ url: URL) -> Void) {
        var req = URLRequest(url: URL(string: url)!)
        req.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
            print(error ?? "")
            guard let data = data, let result = String(data: data, encoding: .utf8) else { return }

            var parameters: [String : String] = [:]
            var par: [[String : String]] = []
            for keyValue in result.split(separator: "&") {
                let keyValueArray = keyValue.split(separator: "=")
                guard let key = keyValueArray.first, let value = keyValueArray.last?.removingPercentEncoding else { continue }
                if key == "url_encoded_fmt_stream_map" {
                    for child in value.split(separator: ",") {
                        var parameters2: [String : String] = [:]
                        for item in child.split(separator: "&") {
                            let keyValueArray2 = item.split(separator: "=")
                            guard let key2 = keyValueArray2.first, let value2 = keyValueArray2.last?.removingPercentEncoding else { continue }
                            parameters2[String(key2)] = value2
                        }
                        par.append(parameters2)
                    }
                }
                parameters[String(key)] = value
            }

            guard let dic = par.first(where: { $0["quality"] == "hd720" }), let url = dic["url"] else { return }
            completion(URL(string: url)!)
        })
        task.resume()
    }

    @IBAction func didTapReloadButton(_ sender: UIBarButtonItem) {
        defer {
            index += 1
            if index >= youtubeUrls.count { index = 0 }
        }
        let urlString = youtubeUrls[index]
        getURL(urlString) { url in
            self.avPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
    }

    @IBAction func didTapPauseButton(_ sender: UIBarButtonItem) {
        avPlayer.pause()
    }

    @IBAction func didTapPlayButton(_ sender: UIBarButtonItem) {
        avPlayer.play()
    }

    @IBAction func didTapRewindButton(_ sender: UIBarButtonItem) {
        avPlayer.seek(to: CMTime(seconds: 0.0, preferredTimescale: 1))
    }

}

