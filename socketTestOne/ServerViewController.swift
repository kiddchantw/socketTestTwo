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


class ServerViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GCDAsyncSocketDelegate {

    
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
    
    

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        addText(text: "connect succuess")
        addText(text: "connect to " + newSocket.connectedHost!)
        addText(text: "port" + String(newSocket.connectedPort))
        clientSocket = newSocket
        
        //clientSocket!.readData(withTimeout: -1, tag: 0)
        clientSocket!.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
    }
    
    
    var count = 0
    var currentPacketHead:[String:AnyObject] = [:]
    var packetLength:UInt!

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        count = count + 1
        
        print("data.count: \(data.count)")
        let dataString:String = String(data: data as Data, encoding: String.Encoding.utf8)!
        
        
        if currentPacketHead.isEmpty {
            print(count)
            print("currentPacketHead.isEmpty")
            //print(dataString)

            do {
                currentPacketHead = try JSONSerialization.jsonObject(with: data , options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                let type:String = currentPacketHead["type"] as! String
                print("type \(type)")
                
                if currentPacketHead.isEmpty {
                    print("error:currentPacketHead.isEmpty")
                    return
                }
                packetLength = currentPacketHead["size"] as! UInt
                print("packet Length: \(packetLength)")
                sock.readData(toLength: UInt(packetLength), withTimeout: -1, tag: 0)
                return
                
            }catch let error as NSError {
                print(error)
            }
        }else{
            print(count)
            print("currentPacketHead not Empty")
            //print(dataString)

            
            let packetLength2:UInt = currentPacketHead["size"] as! UInt
            
            if UInt(data.count) != packetLength2 {
                return;
            }
            var type2:String = currentPacketHead["type"] as! String
            print("type2 \(type2)")
            
            if type2 == "image" {
            
            let jsondic:[String:AnyObject] = convertStringToDictionary(text: dataString)!
            let strBase64 = jsondic["image"] as! String
            let dataDecoded:NSData = NSData(base64Encoded: strBase64 , options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            serverImage.image = decodedimage

            }else if type2 == "text"{
               addText(text: dataString)
            }else{
            
            }
            
            currentPacketHead = [:]
        }
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

