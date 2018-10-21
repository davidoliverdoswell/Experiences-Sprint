//
//  ExperienceController.swift
//  Experiences-Sprint
//
//  Created by David Doswell on 10/20/18.
//  Copyright © 2018 David Doswell. All rights reserved.
//

private var experienceList = "experiencePList"

import Foundation

class ExperienceController {
    private(set) var experiences: [Experience] = []
    
    func createExperience(with title: String?, image: Data?, audio: URL?) {
        
        let experience = Experience(title: title, image: image, audio: audio)
        experiences.append(experience)
        encode()
    }
    
    func updateExperience(with title: String?, image: Data?, audio: URL?) {
        let updatedExperience = Experience(title: title, image: image, audio: audio)
        experiences.append(updatedExperience)
        encode()
    }
    
    func updateVideoURL(with title: String?, image: Data?, audio: URL?) {
        guard let updatedVideoURL = try? Experience(from: audio as! Decoder) else { return }
        experiences.append(updatedVideoURL)
        encode()
    }
    
    var url : URL? {
        let fileManager = FileManager()
        let docDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDirectory.appendingPathComponent(experienceList)
    }
    
    func encode() {
        do {
            guard let url = url else { return }
            
            let encoder = PropertyListEncoder()
            let experienceData = try encoder.encode(experiences)
            try experienceData.write(to: url)
        } catch {
            NSLog("Error encoding: \(error)")
        }
    }
    
    func decode() {
        let fileManager = FileManager()
        do {
            guard let url = url, fileManager.fileExists(atPath: url.path) else { return }
            
            let experienceData = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let decodedExperiences = try decoder.decode([Experience].self, from: experienceData)
            experiences = decodedExperiences
        } catch {
            NSLog("Error decoding: \(error)")
        }
    }
    
}
