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
        var headDic: [String:Any] = [:]
        headDic["type"] = type
        headDic["size"] = "\(size)"
        let jsonStr = convertDictionaryToString(dict: headDic as [String : AnyObject])
        let lengthData = jsonStr.data(using: String.Encoding.utf8)
        mData = NSMutableData.init(data: lengthData!)
        mData.append(GCDAsyncSocket.crlfData())
        mData.append(data as Data)
        
//        print(mData)
//        socket?.write(mData as Data, withTimeout: -1, tag: 0)
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
       // imageDict.setObject(imageData_Base64str, forKey: "img")
        //imageDict.setValue(imageData_Base64str, forKey: "image")
        imageDict["image"] = imageData_Base64str
        //print(imageDict)
        //7-1
        test7str = convertDictionaryToString(dict: imageDict as [String : AnyObject])
        //print(test7str)
        //7-2
        test7data = test7str.data(using: String.Encoding.utf8)
        print(test7data)
        //7-3
        socket?.write(test7data, withTimeout: -1, tag: 0)

        
        
        
        
        //test 6
    
        //imageData  =  NSData.dataWithContentsOfMappedFile(filePath as! String) as! Data!
        //sendPhotoData(data:imageData as NSData,type:"img")
        
        //test 6.1
 /*
        let uploadimg = self.clientImage.image
        imageData = UIImageJPEGRepresentation(uploadimg!, 1)
        //let imageData64 = imageData.base64EncodedData()
        //sendPhotoData(data:imageData64 as NSData,type:"img")
        addText(text: "imageData count\(imageData.count)")
*/
        
        
        //test 5 image to base64string
/*
        let uploadimg = self.clientImage.image
        imageData = UIImageJPEGRepresentation(uploadimg!, 1)
//        let imageData_Base64str = imageData.base64EncodedString() + "\n"
        let imageData_Base64str = imageData.base64EncodedString() + "}"
        socket?.write((imageData_Base64str.data(using: String.Encoding.utf8))!, withTimeout: -1, tag: 0)
  */

        
        
        
        //test 4 image data直接傳base64string+\n轉 data
/*        let uploadimg = self.clientImage.image
        imageData = UIImageJPEGRepresentation(uploadimg!, 1)
        let imageData_Base64str = imageData.base64EncodedString() + "\n"
        sendData = imageData_Base64str.data(using: String.Encoding.utf8)
        socket?.write(sendData!, withTimeout: -1, tag: 1) 
        print(" Test4 sendData.count \(sendData.count)")
 */

        
        
        
        //test 3 image data直接傳        
/*         let uploadimg = self.clientImage.image
           imageData = UIImageJPEGRepresentation(uploadimg!, 1)
           let imageData64 = imageData.base64EncodedData()
           print(imageData64) 
           socket?.write(imageData64, withTimeout: -1, tag: 0)
 */

        
        
        
        
        
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
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
    @IBAction func btnTestGet(_ sender: UIButton) {
        print("btnTestGet start")
        //test 7 ok 可以從 imageDict抓到資料
            //7.2
            let dataString:String = String(data: test7data, encoding: String.Encoding.utf8)!

            //7.1
            let jsondic:[String:AnyObject] = convertStringToDictionary(text: dataString)!
        let strBase64 = jsondic["image"] as! String
        let dataDecoded:NSData = NSData(base64Encoded: strBase64 , options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        //print(decodedimage)
        clientImage.image = decodedimage
        
        
        
        
        
        //let decodedimage =
//        clientImage.image = UIImage(data:imageDict["image"] )
//        let xmlStr:String = String(bytes: imageDict["image"], encoding: String.Encoding.utf8)!
//        let dataDecoded : Data = Data(base64Encoded: xmlStr, options: .ignoreUnknownCharacters)!
//        let decodedimage = UIImage(data: dataDecoded)
//        clientImage.image = decodedimage
        
        
        
        
        
//        let decodedimage = UIImage(data: mData as Data)
//        clientImage.image = decodedimage
        
        //test6 自己接收 失敗 xxx
        //6-3
//        let decodeimage = NSData(bytes: imageData, length: 2)
//        clientImage.image = UIImage(data: decodeimage)

        
        
/*
        //var json: Array<Any>!
        var currentPacketHead:[String:AnyObject] = [:]
        do {
             //currentPacketHead = try JSONSerialization.jsonObject(with: mData as Data, options: []) as! [String : AnyObject]
            
            var json = try JSONSerialization.jsonObject(with: mData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]

            print(json)
            //print(currentPacketHead)
            //currentPacketHead = json as![String:AnyObject]
           
        } catch let error as NSError {
            print(error)
        }

        let packetLength = currentPacketHead["size"]
        print("packet Length: \(packetLength)")
        print("mdata.length: \(mData.length)")
        let type = currentPacketHead["type"]
        print("type \(type)")
*/
        
        
        
//        //test4 接收ok
/*
        print(" btnTestGet: \(sendData.count)")
        let xmlStr:String = String(bytes: sendData!, encoding: String.Encoding.utf8)!
        let dataDecoded : Data = Data(base64Encoded: xmlStr, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        clientImage.image = decodedimage
*/
        
        
        
        //test2ok 圖片解碼  data to image
        //        let imagee = UIImage(data: imageData)
        //        clientImage?.image = imagee
        
        
        //test3失敗 jsondata to image
        /*        var json: Array<Any>!
                        do {
                            let json = try JSONSerialization.jsonObject(with: jsonData , options: [])
                            let jsonitem = json as![String:AnyObject]
                            let txtinfo = jsonitem["txt2"] as! String
                            print(txtinfo)
                    let imageinfo = jsonitem["img"] as! String
                    let dataDecoded:NSData = NSData(base64Encoded: imageinfo, options: NSData.Base64DecodingOptions(rawValue: 0))!
                    clientImage.image = UIImage(data: dataDecoded as Data)!
        
                        } catch {
                            print(error)
         }*/

        print("btnTestGet stop")

    }
 
    


    
    
    @IBAction func sendAct(_ sender: Any) {
        // test1ok 文字傳遞ok
         socket?.write((msgTF.text?.data(using: String.Encoding.utf8))!, withTimeout: -1, tag: 0)
        
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
