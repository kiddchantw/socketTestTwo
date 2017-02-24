//
//  ServerViewController.swift
//  socketTestOne
//
//  Created by 詹啟德 on 2017/2/3.
//  Copyright © 2017年 詹啟德. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import Photos


class ServerViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var portTF: UITextField!
    @IBOutlet weak var msgTF: UITextField!
    @IBOutlet weak var infoTV: UITextView!
    
    var serverSocket: GCDAsyncSocket?
    var clientSocket: GCDAsyncSocket?

    
    @IBOutlet weak var serverImage: UIImageView!
    
    
    @IBAction func sendImage(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func openPic(_ sender: UIButton) {
        if  UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated:true, completion: nil)
        }
    }
    
    var fileURL:URL!
    var filePath:Any!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image1 = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        filePath = NSTemporaryDirectory() + "savedImage.jpg"
        
        print("filepath \(filePath)")
        
        if let dataToSave = UIImageJPEGRepresentation(image1,0.5){
            fileURL = URL(fileURLWithPath: filePath as! String)
            do{
                try dataToSave.write(to: fileURL)
                print("save Image")
                // imageURL = filePath as NSURL
                serverImage.image = UIImage(contentsOfFile:filePath as! String)!
                
            }catch{
                print("Can not save Image")
            }
            //imageURL = fileURL as NSURL
            //print("imageURL\(imageURL)")
        }
        dismiss(animated: true, completion: nil)
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        portTF.delegate = self
        msgTF.delegate = self
        //infoTV.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        portTF.resignFirstResponder()
        msgTF.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        portTF.resignFirstResponder()
        msgTF.resignFirstResponder()
    }
    
    

    func addText(text: String) {
        infoTV.text = infoTV.text.appendingFormat("%@\n", text)
    }
    
    
    @IBAction func listenAct(_ sender: Any) {
        serverSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try serverSocket?.accept(onPort: UInt16(portTF.text!)!)
            addText(text: "port succuess")
        }catch _ {
            addText(text: "port fail")
        }
    }
    
    
    @IBAction func sendAct(_ sender: Any) {
        let data = msgTF.text?.data(using: String.Encoding.utf8)
        //向客户端写入信息   Timeout设置为 -1 则不会超时, tag作为两边一样的标示
        clientSocket?.write(data!, withTimeout: -1, tag: 0)
    }
    
    

   
}

extension ServerViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        addText(text: "connect succuess")
        addText(text: "connect to " + newSocket.connectedHost!)
        addText(text: "port" + String(newSocket.connectedPort))
        clientSocket = newSocket
        
        clientSocket!.readData(withTimeout: -1, tag: 0)
    }
    
    

    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {

        //test0  純文字接收ok
        /*
        let message = String(data: data as Data,encoding: String.Encoding.utf8)
        print(message)
        addText(text: message!)
         */
        
        
        //test1  json文字 接收ok
        //test2  json文字＋圖片  接收失敗
        //server錯誤訊息:
        //Error Domain=NSCocoaErrorDomain Code=3840 "Unterminated string around character 44." UserInfo={NSDebugDescription=Unterminated string around character 44.}
        //Error Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set." UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set.}
        do {
            let json = try JSONSerialization.jsonObject(with: data , options:
                            JSONSerialization.ReadingOptions())
            print(json)
            
            //只有文字沒問題,多了圖片就掛點
            let jsonitem = json as![String:AnyObject]
            print(jsonitem["txt"] as! String)
            
            //let imageinfo = jsonitem["img"] as! String
            //let dataDecoded:NSData = NSData(base64Encoded: imageinfo, options: NSData.Base64DecodingOptions(rawValue: 0))!
            //serverImage.image = UIImage(data: dataDecoded as Data)!
        } catch {
            print(error)
        }

        
        
        
        
        //test 3 純iamge data 
        //server錯誤訊息： fatal error: unexpectedly found nil while unwrapping an Optional value
        let message = String(data: data as Data,encoding: String.Encoding.utf8)
        let dataDecoded:NSData = NSData(base64Encoded: message!, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        serverImage.image = decodedimage
        
       
        
//        print("data\(data)")
////        serverImage.image = UIImage(data: data)
//        serverImage.image  = UIImage(data: (data as NSData) as Data)
        

        
//        var currentPacketHead:Array<Any>!
//        do{
//          currentPacketHead = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
//        }catch{
//            print(error)
//        }
        
        
//        無效
//        var json: Array<Any>!
//        do {
//            print("json get")
//            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
//            print("json: \(json)")
//        } catch {
//            print("json not get")
//            print(error)
//        }
//        let dictResult = json[0] as! NSDictionary
//        print(dictResult)
//        //
        
        
//        let item:Dictionary<String,AnyObject> = (json as? Dictionary<String,AnyObject>)!
//        print(item["txt"])
        
//        if let item = json as? [String: AnyObject] {
//            print("item  \(item)")
//            //            if let person = item["person"] as? [String: AnyObject] {
////                if let age = person["age"] as? Int {
////                    print("Dani's age is \(age)")
////                }
////            }
//        }
        
//        let message = String(data: data as Data,encoding: String.Encoding.utf8)
//        if let dict = convertStringToDictionary(text: message!) {
//            print("dict sever")
//            let str1 = dict["txt"] as! String
//            print("str1 \(str1)")
//
//        }
//        print(message!)
        
//        do {
//            let json = try JSONSerialization.jsonObject(with: data , options:
//                JSONSerialization.ReadingOptions())
//            
//            //as! [String:String]
//            //allowFragments
//            //let jsonitem = json //as![String:AnyObject]
//        
//            print(json)
//            //只有文字沒問題,多了圖片就掛點
//           // print(jsonitem["txt"] as! String)
//            
//            //let imageinfo = jsonitem["img"] as! String
//            //let dataDecoded:NSData = NSData(base64Encoded: imageinfo, options: NSData.Base64DecodingOptions(rawValue: 0))!
//            //serverImage.image = UIImage(data: dataDecoded as Data)!
//            
//            
//            
//        } catch {
//            print(error)
//        }
        
        
//        print("read  data.count: \(data.count)")
//        print(data)
//        let clientImage = UIImage(data: data)
//        serverImage.image = clientImage

        /*
         let message = String(data: data as Data,encoding: String.Encoding.utf8)
//        let dict = convertToDictionary(text:message!)
        var dictonary:NSDictionary?
//        if (message?.data(using: String.Encoding.utf8)) != nil {
        let jsondata = message!.data(using: String.Encoding.utf8)
            do {
                dictonary =  try JSONSerialization.jsonObject(with: jsondata!, options: .mutableContainers) as? [String:AnyObject] as NSDictionary?
                //print(dictonary)
//                if let myDictionary = dictonary
//                {
//                    print("\(myDictionary["img"]!)")
//                }
            } catch let error as NSError {
                print(error)
            }
//        }

        //print(message!)
*/
        
        

        
//        var dict10: Dictionary<String, String> = data as Dictionary<String,String>
        
        //print(dic)
        //print("json string = \(jsonString)")
        
//        if let json = try? JSONSerialization.data(withJSONObject: jsonString, options: []) {
//            print(json)
//        }

//        let data = data.dataUsingEncoding(NSUTF8StringEncoding)
        //let datajson = data.data(using: String.Encoding.utf8)
        
//        let json =  try JSONSerialization.jsonObject(with: message, options: []) as? [String: Any]
//        let json = try JSONSerialization.jsonObject(with: datajson, options: .mutableContainers) as? [String:Any]

        
        
        
        
        
        
    
        /*
//       do {
//            print("decode start")
//            let path = Bundle.main.path(forResource: "data", ofType: "json")
//            //let datajson = NSData.dataWithContentsOfFile(path, options: NSData.ReadingOptions.uncached, error: nil)
//            let datajson = NSData.dataWithContentsOfMappedFile(path!)
//            print(datajson as Any)
//            
            

            
        
            
            
            
            
//            let decoded = try JSONSerialization.jsonObject(with: data, options: [])
//            print(decoded)
//            print("decoded init" )
//            let jsonCaseinfo = decoded as! [String:String]
//            print("jsonCaseinfo ok")
//            let str1 = jsonCaseinfo["txt"]! as String
//            print(str1)
//            addText(text: "jsonCaseinfo ok")

            
//            let fileBase64 = jsonCaseinfo["img"]! as String
//            let imageData = Data(base64Encoded: fileBase64, options:.ignoreUnknownCharacters)
//            print("imageData get")
  //          serverImage.image = UIImage(data: imageData!)

            
            
//            let dataDecoded:NSData = NSData(base64Encoded: jsonCaseinfo["img"]!, options: NSData.Base64DecodingOptions(rawValue: 0))!
//            print("dataDecoded ok")
//            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
//            
//            print("decodedimage ok")
//            serverImage.image = decodedimage


            
            // here "decoded" is of type `Any`, decoded from JSON data
//            print("decoded ok")
//            // you can now cast it with the right type
//            if decoded is [String:String] {
////            // use dictFromJSON
//                
//
//            }
//
//        } catch {
//            print("error")
//            print(error.localizedDescription)
//        }
//        
//        
        */
        
        //圖片失敗

       
        

        
        
        
        //再次准备读取Data,以此来循环读取Data
        sock.readData(withTimeout: -1, tag: 0)
        print("GCDAsyncSocket, didRead finish")
    }
    
}

