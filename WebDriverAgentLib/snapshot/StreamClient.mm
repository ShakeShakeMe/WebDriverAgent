#import "StreamClient.h"
#import <Foundation/Foundation.h>
#import <iostream>

#include <TargetConditionals.h>
#import "XCUIDevice+FBHelpers.h"


@interface VideoSource : NSObject
@property (assign) StreamClient *mClient;
@property (nonatomic, strong) dispatch_queue_t snapshotQueue;
@property (nonatomic, strong) dispatch_source_t timer;

- (id) init:(StreamClient *)client;
- (void) start;
- (void) stop;

@end

@implementation VideoSource

- (id) init:(StreamClient *)client {
  self = [super init];
  if (self) {
    self.mClient = client;
    self.snapshotQueue = dispatch_queue_create("FetchSnapshotQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
  }
  return self;
}

- (void) start {
  self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.snapshotQueue);
  dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
  dispatch_source_set_event_handler(self.timer, ^{ 
    [self  captureSnapshot];
  });
  dispatch_resume(self.timer);
}

- (void) stop {
  if (self.timer) {
    dispatch_source_cancel(self.timer);
    self.timer = nil;
  }
}

- (void) captureSnapshot {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error;
    NSData *screenshotData = [[XCUIDevice sharedDevice] fb_screenshotWithError:&error];
    dispatch_async(self.snapshotQueue, ^{
      if (screenshotData) {
        UIImage *image = [UIImage imageWithData:screenshotData];
        CVPixelBufferRef buffer = [self pixelBufferFromCGImage:image.CGImage];
        NSLog(@"Success capture snapshot, size: %@", NSStringFromCGSize(image.size));
        self.mClient->captureOutput(buffer);
      }
    });
  });
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
  // set pixel buffer attributes so we get an iosurface
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           @YES, kCVPixelBufferCGImageCompatibilityKey,
                           @YES, kCVPixelBufferCGBitmapContextCompatibilityKey,
                           nil];
  CVPixelBufferRef pixelBuffer = NULL;
  CGFloat frameWidth = CGImageGetWidth(image);
  CGFloat frameHeight = CGImageGetHeight(image);
  CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                        frameWidth,
                                        frameHeight,
                                        kCVPixelFormatType_32ARGB,
                                        (__bridge CFDictionaryRef)options,
                                        &pixelBuffer);
  
  NSParameterAssert(status == kCVReturnSuccess && pixelBuffer != NULL);
  if (status != kCVReturnSuccess) {
    return NULL;
  }
//  NSLog(@"[INFO IMAGE] Width %f, Height %f, Byte per row %zi", frameWidth, frameHeight, CVPixelBufferGetBytesPerRow(pixelBuffer));
  
  CVPixelBufferLockBaseAddress(pixelBuffer, 0);
  void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);
  NSParameterAssert(pxdata != NULL);
  
  CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(pxdata,
                                               frameWidth,
                                               frameHeight,
                                               CGImageGetBitsPerComponent(image),
                                               CVPixelBufferGetBytesPerRow(pixelBuffer),
                                               rgbColorSpace,
                                               (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
  NSParameterAssert(context);
  
  CGContextConcatCTM(context, CGAffineTransformIdentity);
  CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
  CGColorSpaceRelease(rgbColorSpace);
  CGContextRelease(context);
  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
  
//  NSLog(@"[INFO IMAGE] return pixel buffer done");
  return pixelBuffer;
}

@end

struct StreamClientImpl {
    VideoSource* mVideoSource;
};

StreamClient::StreamClient() {
  impl = new StreamClientImpl();
  impl->mVideoSource = [[VideoSource alloc] init: this];
  
  mBuffer = 0;
  mLockedBuffer = 0;
}

StreamClient::~StreamClient() {
    delete impl;
    if (mBuffer) {
        CFRetain(mBuffer);
    }
    if (mLockedBuffer) {
        CFRetain(mLockedBuffer);
    }
}

void StreamClient::start() {
  [impl->mVideoSource start];
}

void StreamClient::stop() {
    [impl->mVideoSource stop];
}

void StreamClient::captureOutput(CVPixelBufferRef buffer) {
    FrameListener *listener = NULL;

    { // scope for the lock
        std::lock_guard<std::mutex> lock(mMutex);
        if (!mBuffer) {
            listener = mFrameListener;
        }
        mBuffer = buffer;
    }

    if (listener) {
        listener->onFrameAvailable();
    }
}

void StreamClient::setFrameListener(FrameListener *listener) {
    mFrameListener = listener;
}

void StreamClient::lockFrame(Frame *frame) {
    std::lock_guard<std::mutex> lock(mMutex);

    if (!mBuffer) {
        // TODO: handle don't have buffer to lock
        std::cout << "Trying to lockFrame without buffer" << std::endl;
        return;
    }

    if (mLockedBuffer) {
        // TODO: handle already have locked buffer
        std::cout << "Trying to lockFrame, but already have a locked buffer" << std::endl;
        return;
    }

    mLockedBuffer = mBuffer;
    mBuffer = nil;

//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(mLockedBuffer);

    CVPixelBufferLockBaseAddress(mLockedBuffer, kCVPixelBufferLock_ReadOnly);
    frame->width = CVPixelBufferGetWidth(mLockedBuffer);
    frame->height = CVPixelBufferGetHeight(mLockedBuffer);
    frame->data = CVPixelBufferGetBaseAddress(mLockedBuffer);
    frame->size = CVPixelBufferGetDataSize(mLockedBuffer);
    frame->bytesPerRow = CVPixelBufferGetBytesPerRow(mLockedBuffer);
}

void StreamClient::releaseFrame(Frame *frame) {
    std::lock_guard<std::mutex> lock(mMutex);

    if (!mLockedBuffer) {
        // TODO: handle releasing frame without locked buffer
        std::cout << "Trying to releaseFrame without locked buffer" << std::endl;
        return;
    }

    CVPixelBufferUnlockBaseAddress(mLockedBuffer, kCVPixelBufferLock_ReadOnly);
    CFRelease(mLockedBuffer);
    mLockedBuffer = 0;
}
