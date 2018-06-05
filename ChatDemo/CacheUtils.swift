//
//  CacheUtils.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 26/07/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class CacheUtils {
    
    private static let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    private static let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/"
    private static let fileManager = FileManager.default
    
    static func read(from path: String) -> Data? {
        let finalPath = cachesPath + path
        let input = FileHandle(forReadingAtPath: finalPath)
        if (input == nil) {
            return nil
        }
        let data = input?.readDataToEndOfFile()
        input?.closeFile()
        return data
    }
    
    static func write(to path: String, data: Data) {
        let finalPath = cachesPath + path
        fileManager.createFile(atPath: finalPath, contents: data, attributes: nil)
    }
    
    static func clearAudioCache() {
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: cachesPath)
            for filePath in filePaths {
                print(filePath)
                try fileManager.removeItem(atPath: cachesPath + filePath)
            }
        } catch {
            print("Could not clear audio cache: \(error)")
        }
    }
    
    static func clearDocuments() {
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: documentsPath)
            for filePath in filePaths {
                print(filePath)
                try? fileManager.removeItem(atPath: documentsPath + filePath)
            }
        } catch {
            print("Could not clear audio cache: \(error)")
        }
    }
    
}
