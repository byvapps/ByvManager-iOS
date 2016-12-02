//
//  Sockets.swift
//  Pods
//
//  Created by Adrian Apodaca on 8/11/16.
//
//

/*
import Foundation
import SocketIO

public struct Sockets {
    
    public static let socket = SocketIOClient(socketURL: URL(string: Environment.baseUrl() + "/device")!, config: [.log(true), .forcePolling(true)])
    
    public init() {
        Sockets.socket.on("connect") {data, ack in
            print("socket connected")
            
            if let pushId = Device().pushId, let deviceId = Device.id {
                Sockets.socket.emit("pushId", pushId)
                Sockets.socket.once("notification", callback: { data, ack in
                    print("Notification Socket:")
                    debugPrint(data)
                    ack.with()
                })
                Sockets.socket.once("/api/devices/\(deviceId):update", callback: { data, ack in
                    print("Device Updated:")
                    debugPrint(data)
                    ack.with()
                })
            }
        }
    }
    
    public func connect() {
        Sockets.socket.joinNamespace("/device")
        Sockets.socket.connect()
    }
    
    public func disconnect() {
        Sockets.socket.disconnect()
    }
}
*/
