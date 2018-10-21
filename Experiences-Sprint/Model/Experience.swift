//
//  Experience.swift
//  Experiences-Sprint
//
//  Created by David Doswell on 10/20/18.
//  Copyright © 2018 David Doswell. All rights reserved.
//

import Foundation

class Experience: NSObject, Codable {
    var title: String?
    var image: Data?
    var audio: URL?
    
    init(title: String?, image: Data?, audio: URL?) {
        self.title = title
        self.image = image
        self.audio = audio
    }
}

class Video: NSObject, Codable {
    var video: URL?

    init(video: URL?) {
        self.video = video
    }
}
