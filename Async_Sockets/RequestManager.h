
#import <Foundation/Foundation.h>
#import "usbMessage.h"
#import "usb_Data.h"

@interface RequestManager : NSObject
{
    u8 mediaSource;
    u8 tabState;
    u8 tabInfo;
}

- (void)setMediaSource:(u8)source;
- (void)setTabletState:(u8)state;
- (void)setTabletInfo:(u8)info;

- (id)init;
- (NSData *)GetQueryUSBReady:(u8)mediaType folderName:(NSString*)folderName withFileSize:(u32)fileSize;
- (NSData *)GetRequest:(file_complete_response_t)completeresponse cmdID:(u8)cmd;
- (NSData *)GetRequest:(u8)cmdID;
- (NSData *)GetDisconnectRequest:(u8)status;
- (NSData *)GetRequestForCreateFolder:(u8)cmdID folderName:(NSString*)folderName;
- (NSData *)GetRequestForDeleteFlash:(u8)cmdID folderName:(NSString*)folderName fileName:(NSString*)fileName;
- (uint8_t)doCRC:(uint8_t *)inbuffer withSize:(uint32_t)sizer;
- (NSData *)setKeyBoardMap:(int)key;
- (NSData* )GetSendFile:(u32)fileSize fileName:(NSString*)fileName folderName:(NSString*)folderName mediaType:(u8)mediaType;
- (NSData *)CaptureImageOrVideo:(u8)cmdID mediaTarget:(u8)mediaTarget mediaSource:(u8)source;
- (NSData *)setColor:(int)hue sat:(int)sat phase:(int)phase;
- (NSData *)setWhiteBalance:(int)white;
- (NSData *)setLightSource:(int)lightStatus;
- (NSData *)setSharpness:(int)sharpness;
- (NSData *)setZoom:(int)zoom;
- (NSData *)setButtonMap:(int)button1 button2:(int)button2 button3:(int)button3 shortButton1:(int)sb1 shortButton2:(int)sb2 shortButton3:(int)sb3;
- (NSData *)setELC:(int)elc;
- (NSData *) setProfile:(int)hue sat:(int)sat phase:(int)phase white:(int)white sharpness:(int)sharpness zoom:(int)zoom elc:(int)elc button1:(int)b1 button2:(int)b2 button3:(int)b3 shortbutton1:(int)sb1 shortbutton2:(int)sb2 shortbutton3:(int)sb3 profileName:(NSString *)profileName mediaTarget:(u8)mediaTarget procedureindex:(int)index;
- (NSData *)setActiveProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target;
- (NSData *) getProfile:(int)profile;
- (NSData *)GetRequest:(u8)cmdID mediaSource:(u8)source;

@end
