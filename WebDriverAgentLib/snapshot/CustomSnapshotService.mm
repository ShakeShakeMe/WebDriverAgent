//
//  CustomSnapshotService.m
//  WebDriverAgentLib
//
//  Created by dl on 2018/11/10.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "CustomSnapshotService.h"

#include <iostream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>

#include "SimpleServer.hpp"
#include "FrameListener.hpp"
#include "JpegEncoder.hpp"
#include "StreamClient.h"

@interface CustomSnapshotService()
@property (nonatomic, strong) NSMutableArray *connections;
@end

@implementation CustomSnapshotService {
  FrameListener gWaiter;
}

+ (instancetype) sharedInstance {
  static CustomSnapshotService *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[CustomSnapshotService alloc] init];
    instance.connections = [@[] mutableCopy];
  });
  return instance;
}

static ssize_t pumps(int fd, unsigned char* data, size_t length) {
  do {
    // SIGPIPE is set to ignored so we will just get EPIPE instead
    ssize_t wrote = send(fd, data, length, 0);
    
    if (wrote < 0) {
      return wrote;
    }
    
    data += wrote;
    length -= wrote;
  }
  while (length > 0);
  
  return 0;
}

- (void) startServer {
  static StreamClient client;
  client.setFrameListener(&gWaiter);
  client.start();
  if (!gWaiter.waitForFrame()) {
    return EXIT_SUCCESS;
  }
  client.stop();
  
  Frame frame;
  client.lockFrame(&frame);
  std::cout << "resolution: " << frame.width << "x" << frame.height << std::endl;
  static JpegEncoder encoder(&frame);
  client.releaseFrame(&frame);
  
  
//  dispatch_queue_t snapshotQueue = dispatch_queue_create("SendSnapshotQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
//  dispatch_async(snapshotQueue, ^{
//    NSLog(@"ssssssssssssssssssssssssssssssss");
//  });
  SimpleServer server;
  if (server.start(9999) > 0) {
    std::cout << "Server started with port: 9999" << std::endl;
  }
  int socket;
  
  unsigned char frameSize[4];
  while (gWaiter.isRunning() and (socket = server.accept()) > 0) {
    std::cout << "New client connection" << std::endl;
    
    client.start();
    while (gWaiter.isRunning() and gWaiter.waitForFrame() > 0) {
      client.lockFrame(&frame);
      encoder.encode(&frame);
      client.releaseFrame(&frame);
      putUInt32LE(frameSize, encoder.getEncodedSize());
      if ( pumps(socket, frameSize, 4) < 0 ) {
        break;
      }
      if ( pumps(socket, encoder.getEncodedData(), encoder.getEncodedSize()) < 0 ) {
        break;
      }
      NSLog(@"Success send image, data size: %@", @(encoder.getEncodedSize()));
    }
    client.stop();
  }
}

@end
