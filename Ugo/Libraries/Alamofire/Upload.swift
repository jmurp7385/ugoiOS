// Upload.swift
//
// Copyright (c) 2014–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

extension Manager {
    fileprivate enum Uploadable {
        case data(Foundation.URLRequest, Foundation.Data)
        case file(Foundation.URLRequest, URL)
        case stream(Foundation.URLRequest, InputStream)
    }

    fileprivate func upload(_ uploadable: Uploadable) -> Request {
        var uploadTask: URLSessionUploadTask!
        var HTTPBodyStream: InputStream?

        switch uploadable {
        case .data(let request, let data):
            queue.sync {
                uploadTask = self.session.uploadTask(with: request, from: data)
            }
        case .file(let request, let fileURL):
            queue.sync {
                uploadTask = self.session.uploadTask(with: request, fromFile: fileURL)
            }
        case .stream(let request, var stream):
            queue.sync {
                uploadTask = self.session.uploadTask(withStreamedRequest: request)
            }

            HTTPBodyStream = stream
        }

        let request = Request(session: session, task: uploadTask)

        if HTTPBodyStream != nil {
            request.delegate.taskNeedNewBodyStream = { _, _ in
                return HTTPBodyStream
            }
        }

        delegate[request.delegate.task] = request.delegate

        if startRequestsImmediately {
            request.resume()
        }

        return request
    }

    // MARK: File

    /**
        Creates a request for uploading a file to the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: URLRequest The URL request
        :param: file The file to upload

        :returns: The created upload request.
    */
    public func upload(_ URLRequest: URLRequestConvertible, file: URL) -> Request {
        return upload(.file(URLRequest.URLRequest as URLRequest, file))
    }

    /**
        Creates a request for uploading a file to the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: method The HTTP method.
        :param: URLString The URL string.
        :param: headers The HTTP headers. `nil` by default.
        :param: file The file to upload.

        :returns: The created upload request.
    */
    public func upload(_ method: Method, _ URLString: URLStringConvertible, headers: [String: String]? = nil, file: URL) -> Request {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        return upload(mutableURLRequest, file: file)
    }

    // MARK: Data

    /**
        Creates a request for uploading data to the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: URLRequest The URL request.
        :param: data The data to upload.

        :returns: The created upload request.
    */
    public func upload(_ URLRequest: URLRequestConvertible, data: Data) -> Request {
        return upload(.data(URLRequest.URLRequest as URLRequest, data))
    }

    /**
        Creates a request for uploading data to the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: method The HTTP method.
        :param: URLString The URL string.
        :param: headers The HTTP headers. `nil` by default.
        :param: data The data to upload.

        :returns: The created upload request.
    */
    public func upload(_ method: Method, _ URLString: URLStringConvertible, headers: [String: String]? = nil, data: Data) -> Request {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)

        return upload(mutableURLRequest, data: data)
    }

    // MARK: Stream

    /**
        Creates a request for uploading a stream to the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: URLRequest The URL request.
        :param: stream The stream to upload.

        :returns: The created upload request.
    */
    public func upload(_ URLRequest: URLRequestConvertible, stream: InputStream) -> Request {
        return upload(.stream(URLRequest.URLRequest as URLRequest, stream))
    }

    /**
        Creates a request for uploading a stream to the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: method The HTTP method.
        :param: URLString The URL string.
        :param: headers The HTTP headers. `nil` by default.
        :param: stream The stream to upload.

        :returns: The created upload request.
    */
    public func upload(_ method: Method, _ URLString: URLStringConvertible, headers: [String: String]? = nil, stream: InputStream) -> Request {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)

        return upload(mutableURLRequest, stream: stream)
    }

    // MARK: MultipartFormData

    /// Default memory threshold used when encoding `MultipartFormData`.
    public static let MultipartFormDataEncodingMemoryThreshold: UInt64 = 10 * 1024 * 1024

    /**
        Defines whether the `MultipartFormData` encoding was successful and contains result of the encoding as 
        associated values.

        - Success: Represents a successful `MultipartFormData` encoding and contains the new `Request` along with 
                   streaming information.
        - Failure: Used to represent a failure in the `MultipartFormData` encoding and also contains the encoding 
                   error.
    */
    public enum MultipartFormDataEncodingResult {
        case success(request: Request, streamingFromDisk: Bool, streamFileURL: URL?)
        case failure(NSError)
    }

    /**
        Encodes the `MultipartFormData` and creates a request to upload the result to the specified URL request.

        It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative 
        payload is small, encoding the data in-memory and directly uploading to a server is the by far the most 
        efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to 
        be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory 
        foot//print low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be 
        used for larger payloads such as video content.

        The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory 
        or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
        encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk 
        during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding 
        technique was used.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: method                  The HTTP method.
        :param: URLString               The URL string.
        :param: headers                 The HTTP headers. `nil` by default.
        :param: multipartFormData       The closure used to append body parts to the `MultipartFormData`.
        :param: encodingMemoryThreshold The encoding memory threshold in bytes. `MultipartFormDataEncodingMemoryThreshold`
                                        by default.
        :param: encodingCompletion      The closure called when the `MultipartFormData` encoding is complete.
    */
    public func upload(
        _ method: Method,
        _ URLString: URLStringConvertible,
        headers: [String: String]? = nil,
        multipartFormData: (MultipartFormData) -> Void,
        encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
        encodingCompletion: ((MultipartFormDataEncodingResult) -> Void)?)
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)

        return upload(
            mutableURLRequest,
            multipartFormData: multipartFormData,
            encodingMemoryThreshold: encodingMemoryThreshold,
            encodingCompletion: encodingCompletion
        )
    }

    /**
        Encodes the `MultipartFormData` and creates a request to upload the result to the specified URL request.

        It is important to understand the memory implications of uploading `MultipartFormData`. If the cummulative
        payload is small, encoding the data in-memory and directly uploading to a server is the by far the most
        efficient approach. However, if the payload is too large, encoding the data in-memory could cause your app to
        be terminated. Larger payloads must first be written to disk using input and output streams to keep the memory
        foot//print low, then the data can be uploaded as a stream from the resulting file. Streaming from disk MUST be
        used for larger payloads such as video content.

        The `encodingMemoryThreshold` parameter allows Alamofire to automatically determine whether to encode in-memory
        or stream from disk. If the content length of the `MultipartFormData` is below the `encodingMemoryThreshold`,
        encoding takes place in-memory. If the content length exceeds the threshold, the data is streamed to disk
        during the encoding process. Then the result is uploaded as data or as a stream depending on which encoding
        technique was used.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: URLRequest              The URL request.
        :param: multipartFormData       The closure used to append body parts to the `MultipartFormData`.
        :param: encodingMemoryThreshold The encoding memory threshold in bytes. `MultipartFormDataEncodingMemoryThreshold`
                                        by default.
        :param: encodingCompletion      The closure called when the `MultipartFormData` encoding is complete.
    */
    public func upload(
        _ URLRequest: URLRequestConvertible,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        encodingMemoryThreshold: UInt64 = Manager.MultipartFormDataEncodingMemoryThreshold,
        encodingCompletion: ((MultipartFormDataEncodingResult) -> Void)?)
    {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let formData = MultipartFormData()
            multipartFormData(formData)

            let URLRequestWithContentType = (URLRequest.URLRequest as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLRequestWithContentType.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")

            if formData.contentLength < encodingMemoryThreshold {
                let encodingResult = formData.encode()

                DispatchQueue.main.async {
                    switch encodingResult {
                    case .success(let data):
                        let encodingResult = MultipartFormDataEncodingResult.success(
                            request: self.upload(URLRequestWithContentType, data: data),
                            streamingFromDisk: false,
                            streamFileURL: nil
                        )
                        encodingCompletion?(encodingResult)
                    case .failure(let error):
                        encodingCompletion?(.failure(error))
                    }
                }
            } else {
                let fileManager = FileManager.default
                let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
                let directoryURL = tempDirectoryURL.URLByAppendingPathComponent("com.alamofire.manager/multipart.form.data")
                let fileName = UUID().uuidString
                let fileURL = directoryURL.URLByAppendingPathComponent(fileName)

                var error: NSError?

                if fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: &error) {
                    formData.writeEncodedDataToDisk(fileURL) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                encodingCompletion?(.Failure(error))
                            } else {
                                let encodingResult = MultipartFormDataEncodingResult.Success(
                                    request: self.upload(URLRequestWithContentType, file: fileURL),
                                    streamingFromDisk: true,
                                    streamFileURL: fileURL
                                )
                                encodingCompletion?(encodingResult)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        encodingCompletion?(.failure(error!))
                    }
                }
            }
        }
    }
}

// MARK: -

extension Request {

    // MARK: - UploadTaskDelegate

    class UploadTaskDelegate: DataTaskDelegate {
        var uploadTask: URLSessionUploadTask? { return task as? URLSessionUploadTask }
        var uploadProgress: ((Int64, Int64, Int64) -> Void)!

        // MARK: - NSURLSessionTaskDelegate

        // MARK: Override Closures

        var taskDidSendBodyData: ((Foundation.URLSession, URLSessionTask, Int64, Int64, Int64) -> Void)?

        // MARK: Delegate Methods

        func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
            if let taskDidSendBodyData = taskDidSendBodyData {
                taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
            } else {
                progress.totalUnitCount = totalBytesExpectedToSend
                progress.completedUnitCount = totalBytesSent

                uploadProgress?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
            }
        }
    }
}
