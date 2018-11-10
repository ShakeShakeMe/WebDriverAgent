////
////  BBCustomSnapshotService.m
////  WebDriverAgentLib
////
////  Created by dl on 2018/11/10.
////  Copyright © 2018 Facebook. All rights reserved.
////
//
//#import "BBCustomSnapshotService.h"
//#include <sys/socket.h>
//#include <netinet/in.h>
//#include "SnapshotHeader.hpp"
//#import "XCUIDevice+FBHelpers.h"
//#include <turbojpeg.h>
//#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
//
//@interface BBCustomSnapshotService() <GCDAsyncSocketDelegate>
//@property (nonatomic, strong) NSTimer *timer;
//
//@property (nonatomic, assign) int mFd;
//@property (nonatomic, strong) NSMutableArray *connections;
//@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
//@end
//
//@implementation BBCustomSnapshotService
//
//+ (instancetype) sharedInstance {
//  static BBCustomSnapshotService *instance;
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{
//    instance = [[BBCustomSnapshotService alloc] init];
//  });
//  return instance;
//}
//
//- (instancetype)init {
//  self = [super init];
//  if (self) {
//    self.connections = [@[] mutableCopy];
//  }
//  return self;
//}
//
//- (void) startServer {
//  dispatch_queue_t snapshotQueue = dispatch_queue_create("SendSnapshotQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
//  self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:snapshotQueue];
//  [self.asyncSocket acceptOnPort:9999 error:nil];
//}
//
//#pragma mark - GCDAsyncSocketDelegate
//- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
//  [self.connections addObject:newSocket];
//  NSLog(@"Did accept socket, host: %@, port: %@", sock.localHost, @(sock.localPort));
//  [self tryStartTimer];
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//
//}
//
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
//  [self.connections removeObject:sock];
//  if (self.connections.count == 0) {
//    [self stopTimer];
//  }
//  NSLog(@"Did lost socket, host: %@, port: %@", sock.localHost, @(sock.localPort));
//}
//
//- (void) sendSnapshot {
//  dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
//      NSError *error;
//      NSData *screenshotData = [[XCUIDevice sharedDevice] fb_screenshotWithError:&error];
//      if (screenshotData) {
//        Frame frame;
//        NSTimeInterval start = [NSDate date].timeIntervalSince1970;
//        [self readImageData:screenshotData toFrame:&frame];
//        JpegEncoder encoder(&frame);
//        encoder.encode(&frame);
//        NSLog(@"Cost time: %@", @([NSDate date].timeIntervalSince1970 - start));
//        
//        unsigned char frameSize[4];
//        putUInt32LE(frameSize, encoder.getEncodedSize());
//
//        for (GCDAsyncSocket *sock in self.connections) {
////          [sock writeData:[NSData dataWithBytes:frameSize length:4] withTimeout:1.f tag:0];
//          [sock writeData:screenshotData withTimeout:5.f tag:0];
//        }
//      }
//    }
//  });
//}
//
//- (void) readImageData:(NSData *)data toFrame:(Frame *)frame {
//  UIImage *image = [UIImage imageWithData:data];
//  CGImageRef imageRef = image.CGImage;
//  frame->width = CGImageGetWidth(imageRef);
//  frame->height = CGImageGetHeight(imageRef);
//  frame->data = [data bytes];
//  frame->size = frame->width * frame->height;
//  frame->bytesPerRow = 4 * frame->width;
//}
//
//- (void) tryStartTimer {
//  [self stopTimer];
//  self.timer = [NSTimer timerWithTimeInterval:10.f target:self selector:@selector(sendSnapshot) userInfo:nil repeats:YES];
//  [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//  [[NSRunLoop currentRunLoop] run];
//}
//
//- (void) stopTimer {
//  if ([self.timer isValid]) {
//    [self.timer invalidate];
//    self.timer = nil;
//  }
//}
//
//@end
