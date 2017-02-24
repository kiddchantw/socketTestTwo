//
//  ClientViewController.swift
//  socketTestOne
//
//  Created by 詹啟德 on 2017/2/3.
//  Copyright © 2017年 詹啟德. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import Photos


class ClientViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var ipTF: UITextField!
    @IBOutlet weak var portTF: UITextField!
    @IBOutlet weak var msgTF: UITextField!
    @IBOutlet weak var infoTV: UITextView!
    
    var socket: GCDAsyncSocket?

    
    @IBOutlet weak var clientImage: UIImageView!

    @IBOutlet weak var openPhoto: UIButton!
    
    
    
//    var jsonData: NSData!
    var jsonData: Data!
    var imageData:Data!

    @IBAction func sendImage(_ sender: UIButton) {
        
        
        //test 3 image data直接傳        
         let uploadimg = self.clientImage.image
         imageData = UIImageJPEGRepresentation(uploadimg!, 1)
         let imageData64 = imageData.base64EncodedData()
         //print(imageData64)
         socket?.write(imageData64, withTimeout: -1, tag: 0)
        
        
        
        
        
        
        //test2   image data轉json   server讀不到
        
        /*
        let st1 = "hi client"
        let uploadimg = self.clientImage.image
        let imageData = UIImageJPEGRepresentation(uploadimg!, 1)
        let strBase64 = imageData?.base64EncodedString()
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(st1, forKey: "txt")
        jsonObject.setValue(strBase64, forKey: "img")
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
            socket?.write(jsonData, withTimeout: -1, tag: 0)
            print("client socket send")
            
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            if let dict = convertStringToDictionary(text: jsonString) {
                let str1 = dict["txt"] as! String
                print(str1)
            }
            
        } catch _ {
            print ("JSON Failure")
        }
         */

        
        
        
        
        
        //test1ok  client字串轉json  server ok
        /*
        let st1 = "hi client"
        let st2 = "hi client2"
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(st1, forKey: "txt")
        jsonObject.setValue(st2, forKey: "txt2")
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions())
            socket?.write(jsonData, withTimeout: -1, tag: 0)
            print("client socket send")
            
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
                //print("json string = \(jsonString)")
                if let dict = convertStringToDictionary(text: jsonString) {
                //print(dict)
                let str1 = dict["txt"] as! String
                print(str1)
            }
        } catch _ {
            print ("JSON Failure")
        }
        */
        
        


        
        
        
        //送出後移除image
        clientImage.image = nil
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

    
    
    @IBAction func sendAct(_ sender: Any) {
        // test1ok 文字傳遞ok
         socket?.write((msgTF.text?.data(using: String.Encoding.utf8))!, withTimeout: -1, tag: 0)
        
        
        //test2ok 圖片解碼  data to image
//        let imagee = UIImage(data: imageData)
//        clientImage?.image = imagee
        
        
        //test3失敗 jsondata to image
//        var json: Array<Any>!
//                do {
//                    let json = try JSONSerialization.jsonObject(with: jsonData , options: [])
//                    let jsonitem = json as![String:AnyObject]
//                    let txtinfo = jsonitem["txt2"] as! String
//                    print(txtinfo)
        //            let imageinfo = jsonitem["img"] as! String
        //            let dataDecoded:NSData = NSData(base64Encoded: imageinfo, options: NSData.Base64DecodingOptions(rawValue: 0))!
        //            clientImage.image = UIImage(data: dataDecoded as Data)!
//        
//                } catch {
//                    print(error)
//                }
//        
        
        
        
    }

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipTF.delegate = self
        portTF.delegate = self
        msgTF.delegate = self
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /////
    /////
    /////
    
    //開相簿
    @IBAction func openPhoto(_ sender: UIButton) {
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
                clientImage.image = UIImage(contentsOfFile:filePath as! String)!

            }catch{
                print("Can not save Image")
            }
        }
        dismiss(animated: true, completion: nil)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ipTF.resignFirstResponder()
        portTF.resignFirstResponder()

        msgTF.resignFirstResponder()
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ipTF.resignFirstResponder()
        portTF.resignFirstResponder()
        msgTF.resignFirstResponder()
    }
    
    
    func addText(text: String) {
        infoTV.text = infoTV.text.appendingFormat("%@\n", text)
    }
    
    
    
    //連結server
    @IBAction func connectAct(_ sender: Any) {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket?.connect(toHost: ipTF.text!, onPort: UInt16(portTF.text!)!)
            addText(text: "connect success")
        }catch _ {
            addText(text: "connect fail")
        }
    }
    
    
    
    @IBAction func disconnectAct(_ sender: Any) {
        socket?.disconnect()
        addText(text: " socket disconnect")
    }
    
    
    
    
    

}


extension ClientViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        addText(text: "conect to " + host)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msg = String(data: data as Data, encoding: String.Encoding.utf8)
        addText(text: msg!)
        socket?.readData(withTimeout: -1, tag: 0)
    }
    
    
}
