//
//  UIImage+StackBlur.m
//  stackBlur
//
//  Created by Thomas on 07/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+StackBlur.h"


@implementation  UIImage (StackBlur)

// Stackblur algorithm
// from
// http://incubator.quasimondo.com/processing/fast_blur_deluxe.php
// by  Mario Klingemann

- (NSArray *)randColors {
  CGImageRef inImage;
  inImage = self.CGImage;
  CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
  UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
  
  CGContextRef cgctx = CGBitmapContextCreate(m_PixelBuf,
                                             CGImageGetWidth(inImage),
                                             CGImageGetHeight(inImage),
                                             CGImageGetBitsPerComponent(inImage),
                                             CGImageGetBytesPerRow(inImage),
                                             CGImageGetColorSpace(inImage),
                                             CGImageGetBitmapInfo(inImage)
                                             );
  if (cgctx == NULL) { return nil; /* error */ }
  
  size_t w = CGImageGetWidth(inImage);
  size_t h = CGImageGetHeight(inImage);
  NSInteger size = w*h;
  CGRect rect = {{0,0},{w,h}};
  CGContextDrawImage(cgctx, rect, inImage);
  
  unsigned char* colorsRGB = CGBitmapContextGetData(cgctx);
  
  NSMutableArray *randColors = [[NSMutableArray alloc] init];
  
  int offset;
  for (int i=0; i<2; i++) { // 2 random colors
    offset = (arc4random() % size) * 4;
    
    float red = (float)colorsRGB[offset]/255.0f;
    float green = (float)colorsRGB[offset+1]/255.0f;
    float blue = (float)colorsRGB[offset+2]/255.0f;
    
    float l = (0.3*(red) + 0.59*(green) + 0.11*(blue));
    
    if (l > 0.85f) {
      i--;
    } else {
      UIColor *randColor = [UIColor colorWithRed:red
                                           green:green
                                            blue: blue alpha:1];
      
      [randColors addObject:randColor];
    }
  }
  
  return randColors;
}

@end
