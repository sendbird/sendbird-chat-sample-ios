// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum BasicGroupChannelAsset {
  public static let accentColor = BasicGroupChannelColors(name: "AccentColor")
  public static let imgBtnResend = BasicGroupChannelImages(name: "img_btn_resend")
  public static let imgIconEditCamera = BasicGroupChannelImages(name: "img_icon_edit_camera")
  public static let imgIconGeneralFile = BasicGroupChannelImages(name: "img_icon_general_file")
  public static let imgIconImageFileMessagePlaceholder = BasicGroupChannelImages(name: "img_icon_image_file_message_placeholder")
  public static let imgIconImageFileMessagePlaceholderOutgoing = BasicGroupChannelImages(name: "img_icon_image_file_message_placeholder_outgoing")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class BasicGroupChannelColors {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension BasicGroupChannelColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: BasicGroupChannelColors) {
    let bundle = BasicGroupChannelResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct BasicGroupChannelImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = BasicGroupChannelResources.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension BasicGroupChannelImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the BasicGroupChannelImages.image property")
  convenience init?(asset: BasicGroupChannelImages) {
    #if os(iOS) || os(tvOS)
    let bundle = BasicGroupChannelResources.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:enable all
// swiftformat:enable all
