#ifndef IOS_MINICAP_STREAMCLIENT_HPP
#define IOS_MINICAP_STREAMCLIENT_HPP

typedef struct opaqueCMSampleBuffer *CMSampleBufferRef;

#include <cstdio>
#include <cstdint>

#include "FrameListener.hpp"
#include "Frame.hpp"
#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

struct StreamClientImpl;

class StreamClient {
public:
    StreamClient();
    ~StreamClient();
    void start();
    void stop();
    void captureOutput(CVPixelBufferRef buffer);
    void setFrameListener(FrameListener *listener);

    void lockFrame(Frame *frame);
    void releaseFrame(Frame *frame);

private:
    StreamClientImpl *impl;
    FrameListener *mFrameListener;
    std::mutex mMutex;
    CVPixelBufferRef mBuffer;
    CVPixelBufferRef mLockedBuffer;
};


#endif //IOS_MINICAP_STREAMCLIENT_HPP
