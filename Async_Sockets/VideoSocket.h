//
//  VideoSocket.h

//

#import <Foundation/Foundation.h>
#import "usbMessage.h"
#import "usb_Data.h"
#import "usbTypes.h"

/** VideoSocketDelegate.
 
 The delegate of a VideoSocket object must adopt the VideoSocketDelegate protocol.
 
 */
@protocol VideoSocketDelegate <NSObject>
/**Notifies that the video socket has been opened.
 */
- (void)advancedVideoSocketConnected;

/**Notifies that the video socket has been closed.
 */
- (void)advancedVideoSocketDisConnected;

/**Notifies about the file download progress on video socket
 @param totalsize Total Size of the file(Video/Image) being downloaded
 @param current Chunk of total file data received in the current received packet
 @param filename Name of the file coming from the CCU
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)advancedVideoDownloadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType;

/**Notifies about the file downloaded status.
 @param filepath Temporary path where the file being downloaded is stored
 @param filesize Total size of the file being downloaded.
 @param downloadTime Time taken to download the file in seconds
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)advancedVideoDownloaded:(NSString*)filepath fileSize:(NSInteger)filesize downloadTime:(NSTimeInterval)downloadTime mediaType:(u8)mediaType;

/**Notifies that last packet of video file data has been received successfully.
 @param fileReceived - FILE_RECEIVED_ACK if last packet of the video socket has been recevied. FILE_RECEIVED_NACK otherwise.
 */
- (void)advancedSendVideoFileReceivedResponse:(file_complete_response_t)fileReceived;

/**Notifies about the file completion event request response from the tablet to CCU.
 @param fileCompletion - FILE_COMPLETION_ACK or FILE_COMPLETION_NACK.
 */
- (void)advancedSendVideoFileCompletionResponseAck:(file_complete_response_t)fileCompletion;

/**Notifies about the file upload progress on video socket
 @param totalsize Total Size of the Video file being uploaded
 @param current Chunk of total file data uploaded in the current uploaded packet
 @param filename Name of the file being sent to the CCU
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)advancedVideoFileUploadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType;

/**Notifies about the file upload status
 @param filepath Source path of the file on the tablet
 @param filesize Total size of the file being uploaded in bytes.
 @param uploadTime Time taken to upload the file in seconds
 */
-(void)advancedVideoFileUploaded:(NSString*)filepath fileSize:(NSInteger)filesize uploadTime:(NSTimeInterval)uploadTime;

-(void)NACKResponseToFileCompletionEventVideoChannel;

@end

/** This class demonstrates VideoSocket.
 
 This class manages all the requests and responses coming on the Video channel. (Low Priority).
 
 */

@interface VideoSocket : NSThread
@property(nonatomic,readonly)	NSString					*urlString;
@property(nonatomic,readonly)	NSInteger					portNumber;
@property(nonatomic,weak)		id<VideoSocketDelegate>	delegate;

/**
 @param url
 @param port
 */
- (id)initWithURLString:(NSString*)url port:(NSInteger)port;

/** Set the folder path for receiving the file.
 @param path Folder Path to save file.
 */
-(void)setFolderPath:(NSString*)path;

/**
 @param dataArray
 */
-(void)queryUSBToSendFileOnVideoChannel:(NSArray *)dataArray;

/** Sets the local variables for filepath, filename and foldername and invokes the query USB command.
 @param sourceFilePath A source file path.
 @param sourceFileName A source file name.
 @param desstinationFolderPath A destination folder path.
 */
-(void)sendFile:(NSString*)sourceFilePath fileName:(NSString*)sourceFileName folderName:(NSString*)desstinationFolderPath;

/**
 @param filePaths - An array having data associated like upload file name, upload file source & destination folder on CCU
 */
-(void)sendFileToUSB:(NSArray *)filePaths;

/**To determine if there is file transfer from CCU to iPad LENS Application
 @return YES iff File Transfer is taking place from CCU to iPad LENS Application. NO otherwise.
 */
- (BOOL)fileReceptionInProgress;

/**To determine if there is file transfer from iPad LENS Application to CCU
 @return YES iff File Transfer is taking place from iPad LENS Application to CCU. NO otherwise.
 */
- (BOOL)fileTransmissionInProgress;

/**
 */
-(void)bytesReadOnVidChannel;

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
- (void)usbQueeryResponsereceived:(NSArray*)dataArray;

/** Start uploading the data packet by packet.
 */
- (void)startUpload;

/** Creates the file handlers and uploads the data packet by packet.
 */
- (void) uploadFile;

/**Uploads Source file data to CCU Chunk by chunk
 */
- (void) sendChunk;

/** Dispatch writeStream event handling.
 */
-(void)resetData;

void videoSocketWriteStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *info);
@end
