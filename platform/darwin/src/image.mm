#include <mbgl/util/image+MGLAdditions.hpp>

#import <ImageIO/ImageIO.h>
#import <webp/decode.h>

namespace {

template <typename T, typename S, void (*Releaser)(S)>
struct CFHandle {
    CFHandle(T t_): t(t_) {}
    ~CFHandle() { Releaser(t); }
    T operator*() { return t; }
    operator bool() { return t; }
private:
    T t;
};

} // namespace

using CGImageHandle = CFHandle<CGImageRef, CGImageRef, CGImageRelease>;
using CFDataHandle = CFHandle<CFDataRef, CFTypeRef, CFRelease>;
using CGImageSourceHandle = CFHandle<CGImageSourceRef, CFTypeRef, CFRelease>;
using CGDataProviderHandle = CFHandle<CGDataProviderRef, CGDataProviderRef, CGDataProviderRelease>;
using CGColorSpaceHandle = CFHandle<CGColorSpaceRef, CGColorSpaceRef, CGColorSpaceRelease>;
using CGContextHandle = CFHandle<CGContextRef, CGContextRef, CGContextRelease>;

CGImageRef CGImageFromMGLPremultipliedImage(mbgl::PremultipliedImage&& src) {
    // We're converting the PremultipliedImage's backing store to a CGDataProvider, and are taking
    // over ownership of the memory.
    CGDataProviderHandle provider(CGDataProviderCreateWithData(
        NULL, src.data.get(), src.bytes(), [](void*, const void* data, size_t) {
            delete[] reinterpret_cast<const decltype(src.data)::element_type*>(data);
        }));
    if (!provider) {
        return nil;
    }

    // If we successfully created the provider, it will take over management of the memory segment.
    src.data.release();

    CGColorSpaceHandle colorSpace(CGColorSpaceCreateDeviceRGB());
    if (!colorSpace) {
        return nil;
    }

    constexpr const size_t bitsPerComponent = 8;
    constexpr const size_t bytesPerPixel = 4;
    constexpr const size_t bitsPerPixel = bitsPerComponent * bytesPerPixel;
    const size_t bytesPerRow = bytesPerPixel * src.size.width;

    return CGImageCreate(src.size.width, src.size.height, bitsPerComponent, bitsPerPixel,
                         bytesPerRow, *colorSpace,
                         kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast, *provider,
                         NULL, false, kCGRenderingIntentDefault);
}

mbgl::PremultipliedImage MGLPremultipliedImageFromCGImage(CGImageRef src) {
    const size_t width = CGImageGetWidth(src);
    const size_t height = CGImageGetHeight(src);

    mbgl::PremultipliedImage image({ static_cast<uint32_t>(width), static_cast<uint32_t>(height) });

    CGColorSpaceHandle colorSpace(CGColorSpaceCreateDeviceRGB());
    if (!colorSpace) {
        throw std::runtime_error("CGColorSpaceCreateDeviceRGB failed");
    }

    constexpr const size_t bitsPerComponent = 8;
    constexpr const size_t bytesPerPixel = 4;
    const size_t bytesPerRow = bytesPerPixel * width;

    CGContextHandle context(CGBitmapContextCreate(
        image.data.get(), width, height, bitsPerComponent, bytesPerRow, *colorSpace,
        kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
    if (!context) {
        throw std::runtime_error("CGBitmapContextCreate failed");
    }

    CGContextSetBlendMode(*context, kCGBlendModeCopy);
    CGContextDrawImage(*context, CGRectMake(0, 0, width, height), src);

    return image;
}

namespace mbgl {
    
    
    PremultipliedImage decodeWebP(const uint8_t*, size_t);
    
    PremultipliedImage decodeImage(const std::string &source_data) {
        // CoreFoundation does not decode WebP natively.
        size_t size = source_data.size();
        if (size >= 12) {
            const uint8_t* data = reinterpret_cast<const uint8_t*>(source_data.data());
            uint32_t riff_magic = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
            uint32_t webp_magic = (data[8] << 24) | (data[9] << 16) | (data[10] << 8) | data[11];
            if (riff_magic == 0x52494646 && webp_magic == 0x57454250) {
                return decodeWebP(data, size);
            }
        }
        
        CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, reinterpret_cast<const unsigned char *>(source_data.data()), size, kCFAllocatorNull);
        if (!data) {
            throw std::runtime_error("CFDataCreateWithBytesNoCopy failed");
        }
        
        CGImageSourceRef image_source = CGImageSourceCreateWithData(data, NULL);
        if (!image_source) {
            CFRelease(data);
            throw std::runtime_error("CGImageSourceCreateWithData failed");
        }
        
        CGImageRef image = CGImageSourceCreateImageAtIndex(image_source, 0, NULL);
        if (!image) {
            CFRelease(image_source);
            CFRelease(data);
            throw std::runtime_error("CGImageSourceCreateImageAtIndex failed");
        }
        
        CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
        if (!color_space) {
            CGImageRelease(image);
            CFRelease(image_source);
            CFRelease(data);
            throw std::runtime_error("CGColorSpaceCreateDeviceRGB failed");
        }
        

        Size imageSize = *new Size((uint32_t)CGImageGetWidth(image), (uint32_t)CGImageGetHeight(image));
        PremultipliedImage result { imageSize };
        
        CGContextRef context = CGBitmapContextCreate(result.data.get(),
                                                     result.size.width,
                                                     result.size.height,
                                                     8,
                                                     result.stride(),
                                                     color_space,
                                                     kCGImageAlphaPremultipliedLast);
        
        if (!context) {
            CGColorSpaceRelease(color_space);
            CGImageRelease(image);
            CFRelease(image_source);
            CFRelease(data);
            throw std::runtime_error("CGBitmapContextCreate failed");
        }
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
        CGRect rect = {{ 0, 0 }, { static_cast<CGFloat>(result.size.width), static_cast<CGFloat>(result.size.height) }};
        CGContextDrawImage(context, rect, image);
        
        CGContextRelease(context);
        CGColorSpaceRelease(color_space);
        CGImageRelease(image);
        CFRelease(image_source);
        CFRelease(data);
        
        return result;
    }

PremultipliedImage decodeImageOld(const std::string& source) {
    CFDataHandle data(CFDataCreateWithBytesNoCopy(
        kCFAllocatorDefault, reinterpret_cast<const unsigned char*>(source.data()), source.size(),
        kCFAllocatorNull));
    if (!data) {
        throw std::runtime_error("CFDataCreateWithBytesNoCopy failed");
    }

    CGImageSourceHandle imageSource(CGImageSourceCreateWithData(*data, NULL));
    if (!imageSource) {
        throw std::runtime_error("CGImageSourceCreateWithData failed");
    }

    CGImageHandle image(CGImageSourceCreateImageAtIndex(*imageSource, 0, NULL));
    if (!image) {
        throw std::runtime_error("CGImageSourceCreateImageAtIndex failed");
    }

    return MGLPremultipliedImageFromCGImage(*image);
}

} // namespace mbgl
