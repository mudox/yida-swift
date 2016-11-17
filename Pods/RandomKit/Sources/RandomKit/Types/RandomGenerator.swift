//
//  RandomGenerator.swift
//  RandomKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A random generator.
public enum RandomGenerator {

    /// Use arc4random.
    ///
    /// If the OS is Linux, Android, or Windows, `arc4random_buf` will be attempted to be dynamically loaded.
    case arc4random

    /// Use "/dev/random". Does nothing on Windows unless using Cygwin.
    case devRandom

    /// Use "/dev/urandom". Does nothing on Windows unless using Cygwin.
    case devURandom

    /// Use Xoroshiro algorithm.
    ///
    /// More info can be found [here](http://xoroshiro.di.unimi.it/).
    ///
    /// If `threadSafe` is `true`, a mutex will be used to access the internal state.
    case xoroshiro(threadSafe: Bool)

    /// Use custom generator.
    case custom(randomize: (UnsafeMutableRawPointer, Int) -> ())

    /// The default random generator. Initially `xoroshiro(threadSafe: true)`.
    public static var `default` = xoroshiro(threadSafe: true)

    /// Whether `arc4random` is available on the current system.
    public static var arc4randomIsAvailable: Bool {
        #if !os(Linux) && !os(Android) && !os(Windows)
            return true
        #else
            if case .some = _a4r_buf {
                return true
            } else {
                return false
            }
        #endif
    }

    /// Randomize the contents of `buffer` of `size`.
    public func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        switch self {
        case .arc4random:
            _arc4random_buf(buffer, size)
        case .devRandom:
            #if !os(Windows) || CYGWIN
            let fd = open("/dev/random", O_RDONLY)
            read(fd, buffer, size)
            close(fd)
            #endif
        case .devURandom:
            #if !os(Windows) || CYGWIN
            let fd = open("/dev/urandom", O_RDONLY)
            read(fd, buffer, size)
            close(fd)
            #endif
        case let .xoroshiro(threadSafe):
            if threadSafe {
                _Xoroshiro.randomizeThreadSafe(buffer: buffer, size: size)
            } else {
                _Xoroshiro.randomize(buffer: buffer, size: size)
            }
        case let .custom(randomize):
            randomize(buffer, size)
        }
    }

    /// Randomize the contents of `value`.
    public func randomize<T>(value: inout T) {
        randomize(buffer: &value, size: MemoryLayout<T>.size)
    }

}

private struct _Xoroshiro {

    private static var _instance = _Xoroshiro()

    private static var _mutex: pthread_mutex_t = {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        return mutex
    }()

    static func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        _instance.randomize(buffer: buffer, size: size)
    }

    static func randomizeThreadSafe(buffer: UnsafeMutableRawPointer, size: Int) {
        pthread_mutex_lock(&_mutex)
        randomize(buffer: buffer, size: size)
        pthread_mutex_unlock(&_mutex)
    }

    var state: (UInt64, UInt64)

    init(state: (UInt64, UInt64)) {
        self.state = state
    }

    init() {
        self.init(state: (0, 0))
        RandomGenerator.devURandom.randomize(buffer: &state, size: MemoryLayout.size(ofValue: state))
    }

    mutating func randomize(buffer: UnsafeMutableRawPointer, size: Int) {
        let uInt64Buffer = buffer.assumingMemoryBound(to: UInt64.self)
        for i in 0 ..< (size / 8) {
            uInt64Buffer[i] = _random()
        }
        let remainder = size % 8
        if remainder > 0 {
            var remaining = _random()
            let uInt8Buffer = buffer.assumingMemoryBound(to: UInt8.self)
            withUnsafePointer(to: &remaining) { remainingPtr in
                remainingPtr.withMemoryRebound(to: UInt8.self, capacity: remainder) { r in
                    for i in 0 ..< remainder {
                        uInt8Buffer[size - i - 1] = r[i]
                    }
                }
            }
        }
    }

    private mutating func _random() -> UInt64 {
        let (l, k0, k1, k2): (UInt64, UInt64, UInt64, UInt64) = (64, 55, 14, 36)
        let result = state.0 &+ state.1
        let x = state.0 ^ state.1
        state.0 = ((state.0 << k0) | (state.0 >> (l - k0))) ^ x ^ (x << k1)
        state.1 = (x << k2) | (x >> (l - k2))
        return result
    }

}

#if os(Linux) || os(Android) || os(Windows)

private typealias _Arc4random_buf = @convention(c) (ImplicitlyUnwrappedOptional<UnsafeMutableRawPointer>, Int) -> ()

private let _a4r_buf: _Arc4random_buf? = {
    guard let handle = dlopen(nil, RTLD_NOW) else {
        return nil
    }
    defer {
        dlclose(handle)
    }
    guard let a4r = dlsym(handle, "arc4random_buf") else {
        return nil
    }
    return unsafeBitCast(a4r, to: _Arc4random_buf.self)
}()

#endif

/// Performs `arc4random_buf` if OS is not Linux, Android, or Windows. Otherwise it'll try
/// getting the handle for `arc4random_buf` and use the result if successful.
private func _arc4random_buf(_ buffer: UnsafeMutableRawPointer!, _ size: Int) {
    #if !os(Linux) && !os(Android) && !os(Windows)
        arc4random_buf(buffer, size)
    #else
        _a4r_buf?(buffer, size)
    #endif
}
