#ifndef IOS_MINICAP_JPEGENCODER_HPP
#define IOS_MINICAP_JPEGENCODER_HPP


#include <cstdio>

#include <turbojpeg.h>
#include "Frame.hpp"

static void putUInt32LE(unsigned char* data, int value) {
  data[0] = (value >> 0) & 0xFF;
  data[1] = (value >> 8) & 0xFF;
  data[2] = (value >> 16) & 0xFF;
  data[3] = (value >> 24) & 0xFF;
}

class JpegEncoder {
public:
    JpegEncoder(Frame *frame);
    ~JpegEncoder();

    void encode(Frame *frame);
    unsigned char* getEncodedData();
    size_t getEncodedSize();
    unsigned long getBufferSize();

private:
    tjhandle mCompressor;
    int mQuality;
    TJSAMP mSubsampling;
    TJPF mFormat;

    unsigned char* mEncodedData;
    size_t mEncodedSize;
    unsigned long mBufferSize;

};


#endif //IOS_MINICAP_JPEGENCODER_HPP
