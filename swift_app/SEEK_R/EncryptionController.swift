//
//  EncryptionController.swift
//  SEEK_R
//
//  Created by Apprentice on 12/21/16.
//  Copyright © 2016 dbcseekrgroup. All rights reserved.
//

import Foundation
import BigInt
class EncryptionController{
    
    class func encrypt(_ messageBody: String,_ keyN: BigUInt,_ keyEOrD: BigUInt) -> BigUInt {
        typealias Key = (modulus: BigUInt, exponent: BigUInt)
        let key = (keyN,keyEOrD)
        
        func encrypt(_ message: BigUInt, key: Key) -> BigUInt {
            return message.power(key.exponent, modulus: key.modulus)
        } 
        let secret: BigUInt = BigUInt(messageBody.data(using: String.Encoding.utf8)!)
        let cyphertext = encrypt(secret, key: key)
        
        return cyphertext
    }
    
    class func decrypt(_ messageBody: BigUInt,_ privateKeyN: BigUInt,_ privateKeyD: BigUInt) -> String {
        typealias Key = (modulus: BigUInt, exponent: BigUInt)
        let privateKey = (privateKeyN,privateKeyD)
        
        func encrypt(_ message: BigUInt, key: Key) -> BigUInt {
            return message.power(key.exponent, modulus: key.modulus)
        }
        let plaintext = encrypt(messageBody, key: privateKey)
        let received = String(data: plaintext.serialize(), encoding: String.Encoding.utf8)
        print(received!)
        return received!
    }
    
    class func generateKey() -> NSArray{
        func generatePrime(_ width: Int) -> BigUInt {
            while true {
                var random = BigUInt.randomInteger(withExactWidth: width)
                random |= BigUInt(1)
                if random.isPrime() {
                    return random
                }
            }
        }
        let p = generatePrime(100)
        let q = generatePrime(100)
        let n = String(p * q)
        let e: BigUInt = 65537
        let E = String(e)
        let phi = (p - 1) * (q - 1)
        let d = String(e.inverse(phi)!)
//        let publicKey: Key = (n, e)
//        let privateKey: Key = (n, d)
        return [n,E,d]
    }
    
    class  func sendEncryptedMessage(_ username: String,_ message: String,_ locationCoords: String) {
        let urlString = "http://localhost:3000/users/" + username
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let postString = ""
        request.httpBody = postString.data(using: .utf8)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                return
            }
            let json: Any?
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
                print(json ?? "there is no json")
            }
            catch
            {
                return
            }
            guard let server_response = json as? NSDictionary else
            {
                return
            }
            
            // login with session and save it:
            if let publicKey = server_response["user"] as? NSDictionary
            {
                print(publicKey)
                print(publicKey["n"]!)
                let publicKeyN = publicKey["n"] as! String
                let bigintN = BigUInt(publicKeyN)
                print(bigintN)
                print(publicKeyN)
                let publicKeyE = publicKey["e"] as! String
                let bigintE = BigUInt(publicKeyE)
                print(publicKeyE)
                let encryptedMessage = String(EncryptionController.encrypt(message, bigintN!, bigintE!))
                let url = "http://localhost:3000/messages"
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                let session = URLSession.shared
                let postString2 = "message%5Breceiver%5D=\(username)&message%5Bbody%5D=\(encryptedMessage)&message%5Blocation%5D=\(locationCoords)"
                request.httpBody = postString2.data(using: .utf8)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (
                    data, response, error) in
                    guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                        return
                    }
                    let json: Any?
                    do
                    {
                        json = try JSONSerialization.jsonObject(with: data!, options: [])
                        print(json ?? "there is no json")
                    }
                    catch
                    {
                        return
                    }
                    
                })
            task.resume()
            }
        })
        task.resume() // this line placement is important for waiting
    } //end-func

}
