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
public enum CommonModuleAsset {
  public static let imgBtnResend = CommonModuleImages(name: "img_btn_resend")
  public static let imgBtnSendFileMsgNormal = CommonModuleImages(name: "img_btn_send_file_msg_normal")
  public static let imgBtnSendFileMsgPressed = CommonModuleImages(name: "img_btn_send_file_msg_pressed")
  public static let imgBtnSendUserMsgNormal = CommonModuleImages(name: "img_btn_send_user_msg_normal")
  public static let imgBtnSendUserMsgPressed = CommonModuleImages(name: "img_btn_send_user_msg_pressed")
  public static let imgDefaultProfileImage1 = CommonModuleImages(name: "img_default_profile_image_1")
  public static let imgDefaultProfileImage2 = CommonModuleImages(name: "img_default_profile_image_2")
  public static let imgDefaultProfileImage3 = CommonModuleImages(name: "img_default_profile_image_3")
  public static let imgDefaultProfileImage4 = CommonModuleImages(name: "img_default_profile_image_4")
  public static let imgIconEditCamera = CommonModuleImages(name: "img_icon_edit_camera")
  public static let imgIconFailure = CommonModuleImages(name: "img_icon_failure")
  public static let imgIconGeneralFile = CommonModuleImages(name: "img_icon_general_file")
  public static let imgIconImageFileMessagePlaceholder = CommonModuleImages(name: "img_icon_image_file_message_placeholder")
  public static let imgIconImageFileMessagePlaceholderOutgoing = CommonModuleImages(name: "img_icon_image_file_message_placeholder_outgoing")
  public static let imgIconNofiOff = CommonModuleImages(name: "img_icon_nofi_off")
  public static let imgIconRead = CommonModuleImages(name: "img_icon_read")
  public static let imgListChecked = CommonModuleImages(name: "img_list_checked")
  public static let imgListUnchecked = CommonModuleImages(name: "img_list_unchecked")
  public static let logoSendbird = CommonModuleImages(name: "logoSendbird")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct CommonModuleImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = CommonModuleResources.bundle
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

public extension CommonModuleImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the CommonModuleImages.image property")
  convenience init?(asset: CommonModuleImages) {
    #if os(iOS) || os(tvOS)
    let bundle = CommonModuleResources.bundle
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
