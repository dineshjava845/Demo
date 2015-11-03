//
//  ImageSocket.h
//  Gnome
//
//

#import <Foundation/Foundation.h>
#import "usbMessage.h"
#import "usb_Data.h"
#import "usbTypes.h"

/** ImageSocketDelegate.
 
 The delegate of a ImageSocket object must adopt the ImageSocketDelegate protocol.
 
 */

@protocol ImageSocketDelegate <NSObject>
/**Notifies that the image socket has been opened.
 */
- (void)advancedImageSocketConnected;

/**Notifies that the image socket has been closed.
 */
- (void)advancedImageSocketDisConnected;

/**Notifies about the file download progress on image socket
 @param totalsize Total Size of the file(Video/Image) being downloaded
 @param current Chunk of total file data received in the current received packet
 @param filename Name of the file coming from the CCU
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)advancedImageDownloadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType;

/**Notifies about the file downloaded status.
 @param filepath Temporary path where the file being downloaded is stored
 @param filesize Total size of the file being downloaded.
 @param downloadTime Time taken to download the file in seconds
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)advancedImageDownloaded:(NSString*)filepath fileSize:(NSInteger)filesize downloadTime:(NSTimeInterval)downloadTime mediaType:(u8)mediaType;

/**Notifies that last packet of image file data has been received successfully.
 @param fileReceived - FILE_RECEIVED_ACK if last packet of the image socket has been recevied. FILE_RECEIVED_NACK otherwise.
 */
- (void)advancedSendImageFileReceivedResponse:(file_complete_response_t)fileReceived;

/**Notifies about the file completion event request response from the tablet to CCU.
 @param fileCompletion - FILE_COMPLETION_ACK or FILE_COMPLETION_NACK.
 */
- (void)advancedSendImageFileCompletionResponseAck:(file_complete_response_t)fileCompletion;

/**Notifies about the file upload progress on image socket
 @param totalsize Total Size of the image file being uploaded
 @param current Chunk of total file data uploaded in the current uploaded packet
 @param filename Name of the file being sent to the CCU
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)advancedImageFileUploadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType;

/**Notifies about the file upload status
 @param filepath Source path of the file on the tablet
 @param filesize Total size of the file being uploaded in bytes.
 @param uploadTime Time taken to upload the file in seconds
 */
-(void)advancedImageFileUploaded:(NSString*)filepath fileSize:(NSInteger)filesize uploadTime:(NSTimeInterval)uploadTime;


-(void)NACKResponseToFileCompletionEventImageChannel;

@end

/** This class demonstrates ImageSocket.
 
 This class manages all the requests and responses coming on the Image channel.
 
 */

@interface ImageSocket : NSThread
@property(nonatomic,readonly)	NSString					*urlString;
@property(nonatomic,readonly)	NSInteger					portNumber;
@property(nonatomic,weak)		id<ImageSocketDelegate>	delegate;

-(id)initWithURLString:(NSString*)url port:(NSInteger)port;

/** Set the folder path for receiving the file.
 @param path Folder path to save file.
 */
-(void)setFolderPath:(NSString*)path;

/**
 @param dataArray
 */
-(void)queryUSBToSendFileOnImageChannel:(NSArray *)dataArray;

/** Sets the local variables for filepath, filename and foldername and invokes the query USB command.
 @param sourceFilePath A source file path.
 @param sourceFileName A source file name.
 @param desstinationFolderPath A destination folder path.
 */
-(void)sendFile:(NSString*)sourceFilePath fileName:(NSString*)sourceFileName folderName:(NSString*)desstinationFolderPath;

/**
 @param filePaths
 */
-(void)sendFileToUSB:(NSArray *)filePaths;

/**
 @return
 */
- (BOOL)fileReceptionInProgress;

/**
 @return
 */
- (BOOL)fileTransmissionInProgress;

/**
 */
-(void)bytesReadOnImageChannel;

/**
 @param data
 */
- (void)socketDidReadData:(NSData *)data;

/** Updates the downloading file.
 @param data A file data.
 */
-(void)updateDownloadingFile:(NSData *)data;

/** Fetches the amount of storage available on the device.
 @return Storage space available.
 */
- (float)getPercentageOfStorageAvailableOnDevice;

/**
 */
- (void)writeDataBufferToWriteStream;

/**
 @param dataArray
 */
- (void)usbQueryResponsereceived:(NSArray*)dataArray;

/** Start uploading the data packet by packet.
 */
- (void)startUpload;

/** Creates the file handlers and uploads the data packet by packet.
 */
- (void) uploadFile;

/**
 */
- (void) sendChunk;
-(void)resetData;
/** Dispatch writeStream event handling.
 */
void imageSocketWriteStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *info);
@end
