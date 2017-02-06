// Manager.swift
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

/**
    Responsible for creating and managing `Request` objects, as well as their underlying `NSURLSession`.
*/
open class Manager {

    // MARK: - Properties

    /**
        A shared instance of `Manager`, used by top-level Alamofire request methods, and suitable for use directly for any ad hoc requests.
    */
    open static let sharedInstance: Manager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders

        return Manager(configuration: configuration)
    }()

    /**
        Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.

        :returns: The default header values.
    */
    open static let defaultHTTPHeaders: [String: String] = {
        // Accept-Encoding HTTP Header; see http://tools.ietf.org/html/rfc7230#section-4.2.3
        let acceptEncoding: String = "gzip;q=1.0,compress;q=0.5"

        // Accept-Language HTTP Header; see http://tools.ietf.org/html/rfc7231#section-5.3.5
        let acceptLanguage: String = {
            var components: [String] = []
            for (index, languageCode) in enumerate(Locale.preferredLanguages as! [String]) {
                let q = 1.0 - (Double(index) * 0.1)
                components.append("\(languageCode);q=\(q)")
                if q <= 0.5 {
                    break
                }
            }

            return join(",", components)
        }()

        // User-Agent Header; see http://tools.ietf.org/html/rfc7231#section-5.5.3
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable: AnyObject = info[kCFBundleExecutableKey] ?? "Unknown"
                let bundle: AnyObject = info[kCFBundleIdentifierKey] ?? "Unknown"
                let version: AnyObject = info[kCFBundleVersionKey] ?? "Unknown"
                let os: AnyObject = ProcessInfo.processInfo.operatingSystemVersionString as AnyObject? ?? "Unknown" as AnyObject

                var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
                let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString

                if CFStringTransform(mutableUserAgent, nil, transform, 0) == 1 {
                    return mutableUserAgent as String
                }
            }

            return "Alamofire"
        }()

        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent
        ]
    }()

    let queue = DispatchQueue(label: nil, attributes: [])

    /// The underlying session.
    open let session: URLSession

    /// The session delegate handling all the task and session delegate callbacks.
    open let delegate: SessionDelegate

    /// Whether to start requests immediately after being constructed. `true` by default.
    open var startRequestsImmediately: Bool = true

    /// The background completion handler closure provided by the UIApplicationDelegate `application:handleEventsForBackgroundURLSession:completionHandler:` method. By setting the background completion handler, the SessionDelegate `sessionDidFinishEventsForBackgroundURLSession` closure implementation will automatically call the handler. If you need to handle your own events before the handler is called, then you need to override the SessionDelegate `sessionDidFinishEventsForBackgroundURLSession` and manually call the handler when finished. `nil` by default.
    open var backgroundCompletionHandler: (() -> Void)?

    // MARK: - Lifecycle

    /**
        Initializes the Manager instance with the given configuration and server trust policy.

        :param: configuration The configuration used to construct the managed session. `nil` by default.
        :param: serverTrustPolicyManager The server trust policy manager to use for evaluating all server trust challenges. `nil` by default.
    */
    required public init(configuration: URLSessionConfiguration? = nil, serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        self.delegate = SessionDelegate()
        self.session = URLSession(configuration: configuration!, delegate: self.delegate, delegateQueue: nil)
        self.session.serverTrustPolicyManager = serverTrustPolicyManager

        self.delegate.sessionDidFinishEventsForBackgroundURLSession = { [weak self] session in
            if let strongSelf = self {
                strongSelf.backgroundCompletionHandler?()
            }
        }
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Request

    /**
        Creates a request for the specified method, URL string, parameters, and parameter encoding.

        :param: method The HTTP method.
        :param: URLString The URL string.
        :param: parameters The parameters. `nil` by default.
        :param: encoding The parameter encoding. `.URL` by default.
        :param: headers The HTTP headers. `nil` by default.

        :returns: The created request.
    */
    open func request(
        _ method: Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .url,
        headers: [String: String]? = nil)
        -> Request
    {
        let mutableURLRequest = URLRequest(method, URLString, headers: headers)
        let encodedURLRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        return request(encodedURLRequest)
    }

    /**
        Creates a request for the specified URL request.

        If `startRequestsImmediately` is `true`, the request will have `resume()` called before being returned.

        :param: URLRequest The URL request

        :returns: The created request.
    */
    open func request(_ URLRequest: URLRequestConvertible) -> Request {
        var dataTask: URLSessionDataTask!

        queue.sync {
            dataTask = self.session.dataTask(with: URLRequest.URLRequest)
        }

        let request = Request(session: session, task: dataTask)
        delegate[request.delegate.task] = request.delegate

        if startRequestsImmediately {
            request.resume()
        }

        return request
    }

    // MARK: - SessionDelegate

    /**
        Responsible for handling all delegate callbacks for the underlying session.
    */
    public final class SessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
        fileprivate var subdelegates: [Int: Request.TaskDelegate] = [:]
        fileprivate let subdelegateQueue = DispatchQueue(label: nil, attributes: DispatchQueue.Attributes.concurrent)

        subscript(task: URLSessionTask) -> Request.TaskDelegate? {
            get {
                var subdelegate: Request.TaskDelegate?
                subdelegateQueue.sync {
                    subdelegate = self.subdelegates[task.taskIdentifier]
                }

                return subdelegate
            }

            set {
                subdelegateQueue.async(flags: .barrier, execute: {
                    self.subdelegates[task.taskIdentifier] = newValue
                }) 
            }
        }

        // MARK: - NSURLSessionDelegate

        // MARK: Override Closures

        /// NSURLSessionDelegate override closure for `URLSession:didBecomeInvalidWithError:` method.
        public var sessionDidBecomeInvalidWithError: ((Foundation.URLSession, NSError?) -> Void)?

        /// NSURLSessionDelegate override closure for `URLSession:didReceiveChallenge:completionHandler:` method.
        public var sessionDidReceiveChallenge: ((Foundation.URLSession, URLAuthenticationChallenge) -> (Foundation.URLSession.AuthChallengeDisposition, URLCredential?))?

        /// NSURLSessionDelegate override closure for `URLSessionDidFinishEventsForBackgroundURLSession:` method.
        public var sessionDidFinishEventsForBackgroundURLSession: ((Foundation.URLSession) -> Void)?

        // MARK: Delegate Methods

        public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
            sessionDidBecomeInvalidWithError?(session, error as NSError?)
        }

        public func URLSession(_ session: Foundation.URLSession, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: ((Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
            var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential!

            if let sessionDidReceiveChallenge = sessionDidReceiveChallenge {
                (disposition, credential) = sessionDidReceiveChallenge(session, challenge)
            } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                let host = challenge.protectionSpace.host

                if let
                    serverTrustPolicy = session.serverTrustPolicyManager?.serverTrustPolicyForHost(host),
                    let serverTrust = challenge.protectionSpace.serverTrust
                {
                    if serverTrustPolicy.evaluateServerTrust(serverTrust, isValidForHost: host) {
                        disposition = .useCredential
                        credential = URLCredential(trust: serverTrust)
                    } else {
                        disposition = .cancelAuthenticationChallenge
                    }
                }
            }

            completionHandler(disposition, credential)
        }

        public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            sessionDidFinishEventsForBackgroundURLSession?(session)
        }

        // MARK: - NSURLSessionTaskDelegate

        // MARK: Override Closures

        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:`.
        public var taskWillPerformHTTPRedirection: ((Foundation.URLSession, URLSessionTask, HTTPURLResponse, Foundation.URLRequest) -> Foundation.URLRequest?)?

        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:didReceiveChallenge:completionHandler:`.
        public var taskDidReceiveChallenge: ((Foundation.URLSession, URLSessionTask, URLAuthenticationChallenge) -> (Foundation.URLSession.AuthChallengeDisposition, URLCredential?))?

        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:session:task:needNewBodyStream:`.
        public var taskNeedNewBodyStream: ((Foundation.URLSession, URLSessionTask) -> InputStream?)?

        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:`.
        public var taskDidSendBodyData: ((Foundation.URLSession, URLSessionTask, Int64, Int64, Int64) -> Void)?

        /// Overrides default behavior for NSURLSessionTaskDelegate method `URLSession:task:didCompleteWithError:`.
        public var taskDidComplete: ((Foundation.URLSession, URLSessionTask, NSError?) -> Void)?

        // MARK: Delegate Methods

        public func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: Foundation.URLRequest, completionHandler: ((Foundation.URLRequest!) -> Void)) {
            var redirectRequest: Foundation.URLRequest? = request

            if let taskWillPerformHTTPRedirection = taskWillPerformHTTPRedirection {
                redirectRequest = taskWillPerformHTTPRedirection(session, task, response, request)
            }

            completionHandler(redirectRequest)
        }

        public func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: ((Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) {
            if let taskDidReceiveChallenge = taskDidReceiveChallenge {
                completionHandler(taskDidReceiveChallenge(session, task, challenge))
            } else if let delegate = self[task] {
                delegate.URLSession(session, task: task, didReceiveChallenge: challenge, completionHandler: completionHandler)
            } else {
                URLSession(session, didReceiveChallenge: challenge, completionHandler: completionHandler)
            }
        }

        public func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, needNewBodyStream completionHandler: ((InputStream!) -> Void)) {
            if let taskNeedNewBodyStream = taskNeedNewBodyStream {
                completionHandler(taskNeedNewBodyStream(session, task))
            } else if let delegate = self[task] {
                delegate.URLSession(session, task: task, needNewBodyStream: completionHandler)
            }
        }

        public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
            if let taskDidSendBodyData = taskDidSendBodyData {
                taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
            } else if let delegate = self[task] as? Request.UploadTaskDelegate {
                delegate.URLSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
            }
        }

        public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let taskDidComplete = taskDidComplete {
                taskDidComplete(session, task, error as NSError?)
            } else if let delegate = self[task] {
                delegate.urlSession(session, task: task, didCompleteWithError: error)
            }

            self[task] = nil
        }

        // MARK: - NSURLSessionDataDelegate

        // MARK: Override Closures

        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:didReceiveResponse:completionHandler:`.
        public var dataTaskDidReceiveResponse: ((Foundation.URLSession, URLSessionDataTask, URLResponse) -> Foundation.URLSession.ResponseDisposition)?

        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:didBecomeDownloadTask:`.
        public var dataTaskDidBecomeDownloadTask: ((Foundation.URLSession, URLSessionDataTask, URLSessionDownloadTask) -> Void)?

        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:didReceiveData:`.
        public var dataTaskDidReceiveData: ((Foundation.URLSession, URLSessionDataTask, Data) -> Void)?

        /// Overrides default behavior for NSURLSessionDataDelegate method `URLSession:dataTask:willCacheResponse:completionHandler:`.
        public var dataTaskWillCacheResponse: ((Foundation.URLSession, URLSessionDataTask, CachedURLResponse) -> CachedURLResponse?)?

        // MARK: Delegate Methods

        public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (@escaping (Foundation.URLSession.ResponseDisposition) -> Void)) {
            var disposition: Foundation.URLSession.ResponseDisposition = .allow

            if let dataTaskDidReceiveResponse = dataTaskDidReceiveResponse {
                disposition = dataTaskDidReceiveResponse(session, dataTask, response)
            }

            completionHandler(disposition)
        }

        public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
            if let dataTaskDidBecomeDownloadTask = dataTaskDidBecomeDownloadTask {
                dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask)
            } else {
                let downloadDelegate = Request.DownloadTaskDelegate(task: downloadTask)
                self[downloadTask] = downloadDelegate
            }
        }

        public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            if let dataTaskDidReceiveData = dataTaskDidReceiveData {
                dataTaskDidReceiveData(session, dataTask, data)
            } else if let delegate = self[dataTask] as? Request.DataTaskDelegate {
                delegate.urlSession(session, dataTask: dataTask, didReceive: data)
            }
        }

        public func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: ((CachedURLResponse!) -> Void)) {
            if let dataTaskWillCacheResponse = dataTaskWillCacheResponse {
                completionHandler(dataTaskWillCacheResponse(session, dataTask, proposedResponse))
            } else if let delegate = self[dataTask] as? Request.DataTaskDelegate {
                delegate.URLSession(session, dataTask: dataTask, willCacheResponse: proposedResponse, completionHandler: completionHandler)
            } else {
                completionHandler(proposedResponse)
            }
        }

        // MARK: - NSURLSessionDownloadDelegate

        // MARK: Override Closures

        /// Overrides default behavior for NSURLSessionDownloadDelegate method `URLSession:downloadTask:didFinishDownloadingToURL:`.
        public var downloadTaskDidFinishDownloadingToURL: ((Foundation.URLSession, URLSessionDownloadTask, URL) -> Void)?

        /// Overrides default behavior for NSURLSessionDownloadDelegate method `URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:`.
        public var downloadTaskDidWriteData: ((Foundation.URLSession, URLSessionDownloadTask, Int64, Int64, Int64) -> Void)?

        /// Overrides default behavior for NSURLSessionDownloadDelegate method `URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:`.
        public var downloadTaskDidResumeAtOffset: ((Foundation.URLSession, URLSessionDownloadTask, Int64, Int64) -> Void)?

        // MARK: Delegate Methods

        public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            if let downloadTaskDidFinishDownloadingToURL = downloadTaskDidFinishDownloadingToURL {
                downloadTaskDidFinishDownloadingToURL(session, downloadTask, location)
            } else if let delegate = self[downloadTask] as? Request.DownloadTaskDelegate {
                delegate.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
            }
        }

        public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            if let downloadTaskDidWriteData = downloadTaskDidWriteData {
                downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
            } else if let delegate = self[downloadTask] as? Request.DownloadTaskDelegate {
                delegate.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }
        }

        public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
            if let downloadTaskDidResumeAtOffset = downloadTaskDidResumeAtOffset {
                downloadTaskDidResumeAtOffset(session, downloadTask, fileOffset, expectedTotalBytes)
            } else if let delegate = self[downloadTask] as? Request.DownloadTaskDelegate {
                delegate.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
            }
        }
    }
}
