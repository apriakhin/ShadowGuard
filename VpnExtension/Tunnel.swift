// Copyright 2018 The Outline Authors

import Foundation
import NetworkExtension
import os

@objcMembers
public class Tunnel: NSObject, Codable {
    public var id: String?
    public var host: String?
    public var port: String?
    public var method: String?
    public var password: String?
    public var prefix: Data?

    public var config: [String: String] {
        let scalars = prefix?.map{Unicode.Scalar($0)}
        let characters = scalars?.map{Character($0)}
        let prefixStr = String(characters ?? [])

        return [
            "host": host ?? "",
            "port": port ?? "",
            "password": password ?? "",
            "method": method ?? "",
            "prefix": prefixStr
        ]
    }
    
    @objc
    public enum TunnelStatus: Int {
        case connected = 0
        case disconnected = 1
        case reconnecting = 2
    }
    
    public convenience init(id: String, config: [String: Any]) {
        self.init()
        self.id = id
        self.host = config["host"] as? String
        self.password = config["password"] as? String
        self.method = config["method"] as? String
        
        if let port = config["port"] {
            self.port = String(describing: port)
        }
        
        if let prefix = config["prefix"] as? String {
            self.prefix = Data(prefix.utf16.map{UInt8($0)})
        }
    }
    
    public func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    public static func decode(_ jsonData: Data) -> Tunnel? {
        return try? JSONDecoder().decode(Tunnel.self, from: jsonData)
    }
    
    @objc 
    public static func getTunnelNetworkSettings(tunnelRemoteAddress: String) -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: tunnelRemoteAddress)
        
        let vpnAddress = selectVpnAddress(interfaceAddresses: getNetworkInterfaceAddresses())
        let ipv4Settings = NEIPv4Settings(addresses: [vpnAddress], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = getExcludedIpv4Routes()
        settings.ipv4Settings = ipv4Settings
        settings.dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "9.9.9.9", "208.67.222.222", "208.67.220.220"])
        
        return settings
    }
}

func getNetworkInterfaceAddresses() -> [String] {
    var interfaces: UnsafeMutablePointer<ifaddrs>?
    var addresses = [String]()
    
    guard getifaddrs(&interfaces) == 0 else {
        Logger().error("Failed to retrieve network interface addresses")
        return addresses
    }
    
    var interface = interfaces

    while interface != nil {
        if interface!.pointee.ifa_addr.pointee.sa_family == UInt8(AF_INET) {
            let addr = interface!.pointee.ifa_addr!.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
            
            if let ip = String(cString: inet_ntoa(addr), encoding: .utf8) {
                addresses.append(ip)
            }
        }
        
        interface = interface!.pointee.ifa_next
    }
    
    freeifaddrs(interfaces)
    
    return addresses
}

let kVpnSubnetCandidates: [String: String] = [
    "10": "10.111.222.0",
    "172": "172.16.9.1",
    "192": "192.168.20.1",
    "169": "169.254.19.0"
]

func selectVpnAddress(interfaceAddresses: [String]) -> String {
    var candidates = kVpnSubnetCandidates
    
    for address in interfaceAddresses {
        for subnetPrefix in kVpnSubnetCandidates.keys {
            if address.hasPrefix(subnetPrefix) {
                candidates.removeValue(forKey: subnetPrefix)
            }
        }
    }
    
    guard !candidates.isEmpty else {
        return kVpnSubnetCandidates.randomElement()!.value
    }

    return candidates.randomElement()!.value
}

let kExcludedSubnets = [
    "10.0.0.0/8",
    "100.64.0.0/10",
    "169.254.0.0/16",
    "172.16.0.0/12",
    "192.0.0.0/24",
    "192.0.2.0/24",
    "192.31.196.0/24",
    "192.52.193.0/24",
    "192.88.99.0/24",
    "192.168.0.0/16",
    "192.175.48.0/24",
    "198.18.0.0/15",
    "198.51.100.0/24",
    "203.0.113.0/24",
    "240.0.0.0/4"
]

func getExcludedIpv4Routes() -> [NEIPv4Route] {
    var excludedIpv4Routes = [NEIPv4Route]()
    
    for cidrSubnet in kExcludedSubnets {
        if let subnet = Subnet.parse(cidrSubnet) {
            let route = NEIPv4Route(destinationAddress: subnet.address, subnetMask: subnet.mask)
            excludedIpv4Routes.append(route)
        }
    }
    
    return excludedIpv4Routes
}
