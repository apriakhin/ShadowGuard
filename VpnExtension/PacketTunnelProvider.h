// Copyright 2018 The Outline Authors

#ifndef PacketTunnelProvider_h
#define PacketTunnelProvider_h

@import NetworkExtension;
@import CocoaLumberjack;

extern const DDLogLevel ddLogLevel;

@interface PacketTunnelProvider : NEPacketTunnelProvider

typedef NS_ENUM(NSInteger, ErrorCode) {
  noError = 0,
  undefinedError = 1,
  vpnPermissionNotGranted = 2,
  invalidServerCredentials = 3,
  udpRelayNotEnabled = 4,
  serverUnreachable = 5,
  vpnStartFailure = 6,
  illegalServerConfiguration = 7,
  shadowsocksStartFailure = 8,
  configureSystemProxyFailure = 9,
  noAdminPermissions = 10,
  unsupportedRoutingTable = 11,
  systemMisconfigured = 12
};

@end

#endif /* PacketTunnelProvider_h */
