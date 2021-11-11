//
//  ContentView.swift
//  ImageDownsamplingExample
//
//  Created by Monsoir on 2021/11/11.
//

import SwiftUI

struct ContentView: View {

    private let formatter: ByteCountFormatter = {
        let result = ByteCountFormatter()
        result.allowsNonnumericFormatting = false
        result.countStyle = .memory
        return result
    }()

    @State
    private var imageWithoutDownsampling: UIImage = UIImage(
        contentsOfFile: Bundle.main.url(
            forResource: "owl-in-a-minimalistic-forest-2560*1440",
            withExtension: "jpg"
        )!.path
    )!

    private var memorySizeOfImageWithoutDownsampling: Int {
        // https://stackoverflow.com/a/29212494/5211544
        let cgImage = imageWithoutDownsampling.cgImage!
        let result = cgImage.bytesPerRow * cgImage.height
        return result
    }

    private var memorySizeOfImageWithoutDownsamplingReadable: String {
        formatter.string(fromByteCount: Int64(memorySizeOfImageWithoutDownsampling))
    }

    @State
    private var imageWithDownSampling: UIImage = downsample(
        imageAt: Bundle.main.url(
            forResource: "owl-in-a-minimalistic-forest-2560*1440",
            withExtension: "jpg"
        )!,
        to: .init(width: 200, height: 100)
    )!

    private var memorySizeOfImageWithDownsampling: Int {
        let cgImage = imageWithDownSampling.cgImage!
        let result = cgImage.bytesPerRow * cgImage.height
        return result
    }

    private var memorySizeOfImageWithDownsamplingReadable: String {
        formatter.string(fromByteCount: Int64(memorySizeOfImageWithDownsampling))
    }

    var body: some View {
        VStack {
            Text("Showing image without downsampling")
                .padding()
            Image(uiImage: imageWithoutDownsampling)
                .resizable()
                .scaledToFit()
            Text("👆Memory usage: \(memorySizeOfImageWithoutDownsamplingReadable)")

            Spacer()
                .frame(height: 20)

            Text("Showing image without downsampling")
                .padding()
            Image(uiImage: imageWithDownSampling)
                .resizable()
                .scaledToFit()
            Text("👆Memory usage: \(memorySizeOfImageWithDownsamplingReadable)")
        }
        .padding()
    }
}

func downsample(
    imageAt imageURL: URL,
    to pointSize: CGSize,
    scale: CGFloat = UIScreen.main.scale
) -> UIImage? {

    // Create an CGImageSource that represent an image
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
        return nil
    }

    // Calculate the desired dimension
    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

    // Perform downsampling
    let downsampleOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ] as CFDictionary
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
        return nil
    }

    // Return the downsampled image as UIImage
    return UIImage(cgImage: downsampledImage)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
