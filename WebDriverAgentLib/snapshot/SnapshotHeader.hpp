////
////  SnapshotHeader.hpp
////  WebDriverAgentLib
////
////  Created by dl on 2018/11/10.
////  Copyright © 2018 Facebook. All rights reserved.
////
//
//#ifndef SnapshotHeader_hpp
//#define SnapshotHeader_hpp
//
//#include <stdio.h>
//#include <stdint.h>
//#include <turbojpeg.h>
//
//static void putUInt32LE(unsigned char* data, size_t value) {
//  data[0] = (value >> 0) & 0xFF;
//  data[1] = (value >> 8) & 0xFF;
//  data[2] = (value >> 16) & 0xFF;
//  data[3] = (value >> 24) & 0xFF;
//}
//
//enum Format {
//  FORMAT_BGRA_8888     = 0x01,
//  FORMAT_UNKNOWN       = 0x00
//};
//
//struct Frame {
//  void const* data;
//  Format format;
//  size_t width;
//  size_t height;
//  size_t bytesPerRow;
//  size_t size;
//};
//
//class JpegEncoder {
//public:
//  JpegEncoder(Frame *frame);
//  ~JpegEncoder();
//  
//  void encode(Frame *frame);
//  unsigned char* getEncodedData();
//  size_t getEncodedSize();
//  unsigned long getBufferSize();
//  
//private:
//  tjhandle mCompressor;
//  int mQuality;
//  TJSAMP mSubsampling;
//  TJPF mFormat;
//  
//  unsigned char* mEncodedData;
//  size_t mEncodedSize;
//  unsigned long mBufferSize;
//};
//
//#endif /* SnapshotHeader_hpp */
