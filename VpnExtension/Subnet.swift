// Copyright 2018 The Outline Authors

import Foundation

@objcMembers
public class Subnet: NSObject {
    public static func parse(_ cidrSubnet: String) -> Subnet? {
        let components = cidrSubnet.components(separatedBy: "/")
        
        guard components.count == 2 else {
            NSLog("Malformed CIDR subnet")
            return nil
        }
        
        guard let prefix = UInt16(components[1]) else {
            NSLog("Invalid subnet prefix")
            return nil
        }
        
        return Subnet(address: components[0], prefix: prefix)
    }

    public var address: String
    public var prefix: UInt16
    public var mask: String

    public init(address: String, prefix: UInt16) {
        self.address = address
        self.prefix = prefix
        let mask = (0xffffffff as UInt32) << (32 - prefix);
        self.mask = mask.IPv4String()
    }
}

extension UInt32 {
    public func IPv4String() -> String {
        let ip = self
        let a = UInt8((ip>>24) & 0xff)
        let b = UInt8((ip>>16) & 0xff)
        let c = UInt8((ip>>8) & 0xff)
        let d = UInt8(ip & 0xff)
        return "\(a).\(b).\(c).\(d)"
    }
}
