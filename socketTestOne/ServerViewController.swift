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
        
       
        


       
        

        
        
        
        //再次准备读取Data,以此来循环读取Data
        sock.readData(withTimeout: -1, tag: 0)
        print("GCDAsyncSocket, didRead finish")
    }
    
}

