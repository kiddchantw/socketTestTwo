//
//  ClientViewController.swift
//  socketTestOne
//
//  Created by kiddchan on 2017/2/3.
//  Copyright © 2017年 kiddchan. All rights reserved.
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
    
    
    
    func convertDictionaryToString(dict:[String:AnyObject]) -> String {
        var result:String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
            
        } catch {
            result = ""
        }
        return result
    }

    var jsonData: Data!
    var imageData:Data!
    var sendData:Data!
    var mData: NSMutableData!
    
    
    func sendPhotoData(data:NSData,type:String){
        let size = data.length
        addText(text: "size:\(size)")
        var headDic: [String:Any] = [:]
        headDic["type"] = type
        headDic["size"] = size
        let jsonStr = convertDictionaryToString(dict: headDic as [String : AnyObject])
        let lengthData = jsonStr.data(using: String.Encoding.utf8)
        mData = NSMutableData.init(data: lengthData!)
        mData.append(GCDAsyncSocket.crlfData())
        mData.append(data as Data)
        
        print("mData.length \(mData.length)")
        socket?.write(mData as Data, withTimeout: -1, tag: 0)
    }
    

    var test7str:String!
    var imageDict:[String:Any] = [:]
    var test7data:Data!
    //var imageDict = MutableDictionary()

    @IBAction func sendImage(_ sender: UIButton) {
        
        //test 7 
            //You need to convert your UIImage to NSData and then convert that NSData to a NSString which will be base64 string representation of your data.
            //Once you get the NSString* from NSData*, you can add it to your dictionary at key @"image"
        let uploadimg = self.clientImage.image
        imageData = UIImageJPEGRepresentation(uploadimg!, 1)       //UIImage to NSData
        let imageData_Base64str = imageData.base64EncodedString()  //NSData to string
        imageDict["image"] = imageData_Base64str    // dictionary
            //print(imageDict)
        //7-1
        test7str = convertDictionaryToString(dict: imageDict as [String : AnyObject])
            //print(test7str)
        //7-2
        test7data = test7str.data(using: String.Encoding.utf8)
            //print(test7data)
        //7-3
        //socket?.write(test7data, withTimeout: -1, tag: 0)
        //7-4
            sendPhotoData(data: test7data as NSData, type: "image")
        
        
        
        
        
        
        clientImage.image = nil          //送出後移除image

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
    
    
    @IBAction func btnTestGet(_ sender: UIButton) {
        print("btnTestGetPhoto start")
            //7.2
            let dataString:String = String(data: mData as Data, encoding: String.Encoding.utf8)!
                print(dataString)
            //7.1
        /*
            let jsondic:[String:AnyObject] = convertStringToDictionary(text: dataString)!
        let strBase64 = jsondic["image"] as! String
        let dataDecoded:NSData = NSData(base64Encoded: strBase64 , options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        //print(decodedimage)
        clientImage.image = decodedimage
        */
        
        print("btnTestGet end")

    }
 
    


    
    
    @IBAction func sendAct(_ sender: Any) {
        // test1ok 文字傳遞ok
         //socket?.write((msgTF.text?.data(using: String.Encoding.utf8))!, withTimeout: -1, tag: 0)
        
        
        //TEST 7-6
        let txtData:Data = (msgTF.text?.data(using: String.Encoding.utf8))!
        sendPhotoData(data: txtData as NSData, type: "text")
        
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
