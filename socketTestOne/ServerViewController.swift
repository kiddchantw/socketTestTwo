//
//  ServerViewController.swift
//  socketTestOne
//
//  Created by kiddchan on 2017/2/3.
//  Copyright © 2017年 kiddchan. All rights reserved.
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
                serverImage.image = UIImage(contentsOfFile:filePath as! String)!
                
            }catch{
                print("Can not save Image")
            }
        }
        dismiss(animated: true, completion: nil)
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        portTF.delegate = self
        msgTF.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        //test 7-3
        let  dataString:String! = String(data: data, encoding: String.Encoding.utf8)!

        let strSeparate = "]"
        let Separate:Data = strSeparate.data(using: String.Encoding.ascii)!
        sock.readData(to: Separate, withTimeout: -1, tag: 0)

        print("dataString:\(dataString)")
        
        let jsondic:[String:AnyObject] = convertStringToDictionary(text: dataString)!
            //Error Domain=NSCocoaErrorDomain Code=3840 "Unterminated string around character 9." UserInfo={NSDebugDescription=Unterminated string around character 9.}
            //fatal error: unexpectedly found nil while unwrapping an Optional value
        let strBase64 = jsondic["image"] as! String
        let dataDecoded:NSData = NSData(base64Encoded: strBase64 , options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        serverImage.image = decodedimage

        
        
        
        
        
        //test 6
        
        //6-1 Error Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set." UserInfo={NSDebugDescription=JSON text did not start with array or object and option to allow fragments not set.}
/*
        var currentPacketHead:[String:Any] = [:]
        do {
            currentPacketHead = try JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
            

            //currentPacketHead = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
            //6-2 fatal error: 'try!' expression unexpectedly raised an error: Error Domain=NSCocoaErrorDomain Code=3840 "Garbage at end." UserInfo={NSDebugDescription=Garbage at end.}: file /Library/Caches/com.apple.xbs/Sources/swiftlang/swiftlang-800.0.63/src/swift/stdlib/public/core/ErrorType.swift, line 178

        } catch let error as NSError {
            print(error)
        }
        let packetLength = currentPacketHead["size"]
        print("packet Length: \(packetLength)")
        print("data.count: \(data.count)")
        let type = currentPacketHead["type"]
        print("type \(type)")
        serverImage.image = UIImage(data:data)
  */
        
        //currentPacketHead = nil

        
        
        
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
        /*
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
        */
        
        
        //test 3 純iamge data
        //server錯誤訊息： fatal error: unexpectedly found nil while unwrapping an Optional value
/*        let message = String(data: data as Data,encoding: String.Encoding.utf8)
        //let dataDecoded:NSData = NSData(base64Encoded: message!, options: NSData.Base64DecodingOptions(rawValue: 0))!
        
        
        let dataDecoded : Data = Data(base64Encoded: message!, options: .ignoreUnknownCharacters)!
        //test4
        //fatal error: unexpectedly found nil while unwrapping an Optional value
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        self.serverImage.image = decodedimage
  */
       
       
        //test 5 

        /*知道傳來資料的結尾時，可以使用readDataToData：，但這個結尾必須是唯一
         NSData * Separate = [@"}" dataUsingEncoding:NSASCIIStringEncoding];
         [self.asyncSocket readDataToData:Separate withTimeout:-1 tag:0];*/
         /*
        let strSeparate = "}"
        let Separate:Data = strSeparate.data(using: String.Encoding.ascii)!
        sock.readData(to: Separate, withTimeout: -1, tag: 0)
      
        let message = String(data: data as Data,encoding: String.Encoding.utf8)
        let dataDecoded : Data = Data(base64Encoded: message!, options: .ignoreUnknownCharacters)!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        //fatal error: unexpectedly found nil while unwrapping an Optional value
        self.serverImage.image = decodedimage

*/
 
//        sock.readData(withTimeout: -1, tag: 0)
        print("GCDAsyncSocket, didRead finish")
    }
    
}

