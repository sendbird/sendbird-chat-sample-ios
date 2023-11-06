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
public enum BasicOpenChannelAsset {
    public static let accentColor = ModuleColors(name: "AccentColor")
    public static let imgBtnResend = ModuleImages(name: "img_btn_resend")
    public static let imgBtnSendFileMsgNormal = ModuleImages(name: "img_btn_send_file_msg_normal")
    public static let imgBtnSendFileMsgPressed = ModuleImages(name: "img_btn_send_file_msg_pressed")
    public static let imgBtnSendUserMsgNormal = ModuleImages(name: "img_btn_send_user_msg_normal")
    public static let imgBtnSendUserMsgPressed = ModuleImages(name: "img_btn_send_user_msg_pressed")
    public static let imgDefaultProfileImage1 = ModuleImages(name: "img_default_profile_image_1")
    public static let imgDefaultProfileImage2 = ModuleImages(name: "img_default_profile_image_2")
    public static let imgDefaultProfileImage3 = ModuleImages(name: "img_default_profile_image_3")
    public static let imgDefaultProfileImage4 = ModuleImages(name: "img_default_profile_image_4")
    public static let imgIconEditCamera = ModuleImages(name: "img_icon_edit_camera")
    public static let imgIconFailure = ModuleImages(name: "img_icon_failure")
    public static let imgIconGeneralFile = ModuleImages(name: "img_icon_general_file")
    public static let imgIconImageFileMessagePlaceholder = ModuleImages(name: "img_icon_image_file_message_placeholder")
    public static let imgIconImageFileMessagePlaceholderOutgoing = ModuleImages(name: "img_icon_image_file_message_placeholder_outgoing")
    public static let imgIconNofiOff = ModuleImages(name: "img_icon_nofi_off")
    public static let imgIconRead = ModuleImages(name: "img_icon_read")
    public static let imgListChecked = ModuleImages(name: "img_list_checked")
    public static let imgListUnchecked = ModuleImages(name: "img_list_unchecked")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ModuleColors {
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

public extension ModuleColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ModuleColors) {
    let bundle = BasicOpenChannelResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

public struct ModuleImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = BasicOpenChannelResources.bundle
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

public extension ModuleImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the CommonModuleImages.image property")
  convenience init?(asset: ModuleImages) {
    #if os(iOS) || os(tvOS)
    let bundle = BasicOpenChannelResources.bundle
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
