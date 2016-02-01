//
//  WordReader.swift
//  RAMReelExample
//
//  Created by Mikhail Stepkin on 01.02.16.
//  Copyright © 2016 Ramotion. All rights reserved.
//

import Foundation

public final class WordReader {
    
    private(set) public var words: [String] = []
    
    init (filepath: String) throws {
        let fileManager = NSFileManager.defaultManager()
        
        guard fileManager.fileExistsAtPath(filepath) else {
            throw Error.FileDoesntExist(filepath)
        }
        
        guard fileManager.isReadableFileAtPath(filepath) else {
            throw Error.FileIsNotReadable(filepath)
        }
        
        let contents = try String(contentsOfFile: filepath)
        
        guard !contents.isEmpty else {
            throw Error.FileIsEmpty(filepath)
        }
        
        let words = contents.characters.split("\n")
        self.words = words.map(String.init)
    }
    
    enum Error: ErrorType {
        case FileDoesntExist(String)
        case FileIsNotReadable(String)
        case FileIsEmpty(String)
    }
    
}