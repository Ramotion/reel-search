//
//  WordReader.swift
//  RAMReelExample
//
//  Created by Mikhail Stepkin on 01.02.16.
//  Copyright © 2016 Ramotion. All rights reserved.
//

import Foundation

public final class WordReader {
    
    fileprivate(set) public var words: [String] = []
    
    init (filepath: String) throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: filepath) else {
            throw AnError.fileDoesntExist(filepath)
        }
        
        guard fileManager.isReadableFile(atPath: filepath) else {
            throw AnError.fileIsNotReadable(filepath)
        }
        
        let contents = try String(contentsOfFile: filepath)
        
        guard !contents.isEmpty else {
            throw AnError.fileIsEmpty(filepath)
        }
        
        let words = contents.characters.split(separator: "\n")
        self.words = words.map(String.init)
    }
    
    enum AnError: Error {
        case fileDoesntExist(String)
        case fileIsNotReadable(String)
        case fileIsEmpty(String)
    }
    
}
