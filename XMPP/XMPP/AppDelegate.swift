//
//  AppDelegate.swift
//  XMPP
//
//  Created by 蒋进 on 15/12/20.
//  Copyright © 2015年 sijichcai. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

/*
* 在AppDelegate实现登录

1. 初始化XMPPStream
2. 连接到服务器[传一个JID]
3. 连接到服务成功后，再发送密码授权
4. 授权成功后，发送"在线" 消息
*/

//// 1. 初始化XMPPStream
//-(void)setupXMPPStream;
//// 2.连接到服务器
//-(void)connectToHost;
//// 3.连接到服务成功后，再发送密码授权
//-(void)sendPwdToHost;
//// 4.授权成功后，发送"在线" 消息
//-(void)sendOnlineToHost;

class AppDelegate: UIResponder, UIApplicationDelegate,XMPPStreamDelegate {

    var window: UIWindow?
    var _xmppStream: XMPPStream?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
           // 程序一启动就连接到主机
            self.connectToHost()
  
        return true
    }
    
    
    //MARK: - 私有方法
    //MARK:  初始化XMPPStream
    func setupXMPPStream(){
    
    _xmppStream = XMPPStream()
    // 设置代理
    _xmppStream!.addDelegate(self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

    }

    //MARK:  连接到服务器
    func connectToHost(){
        NSLog("开始连接到服务器");
        if (_xmppStream == nil) {
            self.setupXMPPStream()
        }
        
        
        // 设置登录用户JID
        //resource 标识用户登录的客户端 iphone android
        let myJID:XMPPJID = XMPPJID.jidWithUser("lisi", domain: "4jbook-pro.local", resource: "iphone8")
        _xmppStream!.myJID = myJID;
        // 设置服务器域名
        _xmppStream!.hostName = "4jbook-pro.local";//不仅可以是域名，还可是IP地址
        
        // 设置端口 如果服务器端口是5222，可以省略
        _xmppStream!.hostPort = 5222;
        
        // 连接
        //发起连接
        do {
            try _xmppStream!.connectWithTimeout(100000)
            print("发起连接成功")
        }   catch {
            print("发起连接失败")
        }
    
    }
    
    
    //MARK:  连接到服务成功后，再发送密码授权
    func sendPwdToHost(){
        NSLog("再发送密码授权");

        do {
           try _xmppStream!.authenticateWithPassword("123456")
            print("发送密码成功")
        }   catch {
            print("发送密码成功")
            }

    }
    //MARK:   授权成功后，发送"在线" 消息
    func sendOnlineToHost(){
        
        NSLog("发送 在线 消息");
        let presence: XMPPPresence  = XMPPPresence()
        NSLog("%@",presence);
        
        _xmppStream?.sendElement(presence)
  
    }

    //MARK:  -XMPPStream的代理
    //MARK:  与主机连接成功
    func xmppStreamDidConnect(sender:XMPPStream){
    NSLog("与主机连接成功");
    
    // 主机连接成功后，发送密码进行授权
    self.sendPwdToHost()
    }
    
    //MARK:   与主机断开连接
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError?) {
        // 如果有错误，代表连接失败
        if error == nil{
            print("**与主机断开连接")
        }
        print("**与主机断开连接")
    }


    //MARK:  授权成功
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        NSLog("授权成功");
        // 主机连接成功后，发送密码进行授权
        self.sendOnlineToHost()

    }

    
    //MARK:  授权失败
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        NSLog("授权失败 %@",error);
    }

    
    //MARK:  -公共方法
    func logout(){
        // 1." 发送 "离线" 消息"
        
        let offline: XMPPPresence = XMPPPresence(type: "unavailable")
        _xmppStream?.sendElement(offline)
        
        // 2. 与服务器断开连接
        _xmppStream!.disconnect()
    }

    
    
    
    
    
    
    
    
    
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "swift.XMPP" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("XMPP", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

