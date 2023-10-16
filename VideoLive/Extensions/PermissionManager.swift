//
//  PermissionManager.swift
//  VideoLive
//
//  Created by Minhyuk Kim on 2023/09/05.
//

import UIKit
import Photos
import SendbirdUIKit

class PermissionManager {
    static let shared = PermissionManager()

    var currentStatus: SBUPhotoAccessibleStatus {
        var granted: PHAuthorizationStatus
        if #available(iOS 14, *) {
            granted = PHPhotoLibrary.authorizationStatus(
                for: SBUGlobals.photoLibraryAccessLevel.asPHAccessLevel
            )
        } else {
            granted = PHPhotoLibrary.authorizationStatus()
        }
        return SBUPhotoAccessibleStatus.from(granted)
    }

    private init() {}

    func requestPhotoAccessIfNeeded(completion: @escaping (SBUPhotoAccessibleStatus) -> Void) {
        // authorizationStatus
        var granted: PHAuthorizationStatus
        if #available(iOS 14, *) {
            granted = PHPhotoLibrary.authorizationStatus(
                for: SBUGlobals.photoLibraryAccessLevel.asPHAccessLevel
            )
        } else {
            granted = PHPhotoLibrary.authorizationStatus()
        }

        switch granted {
        case .authorized:
            DispatchQueue.main.async {
                completion(.all)
            }
        default:
            // request authorization when not authorized
            let handler: (PHAuthorizationStatus) -> Void = { status in
                DispatchQueue.main.async {
                    let accessibleStatus = SBUPhotoAccessibleStatus.from(status)
                    completion(accessibleStatus)
                }
            }

            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(
                    for: SBUGlobals.photoLibraryAccessLevel.asPHAccessLevel,
                    handler: handler
                )
            } else {
                PHPhotoLibrary.requestAuthorization(handler)
            }
        }
    }

    func requestDeviceAccessIfNeeded(for type: AVMediaType, completion: @escaping (Bool) -> Void) {
        let granted = AVCaptureDevice.authorizationStatus(for: type)
        if granted != .authorized {
            AVCaptureDevice.requestAccess(for: type) { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(true)
        }
    }

    open func showPhotoAccessPermissionAlert() {
        let settingButton = SBUAlertButtonItem(title: SBUStringSet.Settings) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }

        SBUAlertView.show(
            title: SBUStringSet.Alert_Allow_PhotoLibrary_Access,
            message: SBUStringSet.Alert_Allow_PhotoLibrary_Access_Message,
            oneTimetheme: SBUTheme.componentTheme,
            confirmButtonItem: settingButton,
            cancelButtonItem: cancelButton
        )
    }

    open func showCameraAccessPermissionAlert(completionHandler: (() -> Void)? = nil) {
        let settingButton = SBUAlertButtonItem(title: SBUStringSet.Settings) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }

        SBUAlertView.show(
            title: "Please allow camera accessPlease allow camera access.",
            message: "Permission denied.\nTo use this functionality, please allow camera permissions on your mobile device",
            oneTimetheme: SBUTheme.componentTheme,
            confirmButtonItem: settingButton,
            cancelButtonItem: cancelButton,
            dismissHandler: completionHandler
        )
    }

    open func showMicAccessPermissionAlert(completionHandler: (() -> Void)? = nil) {
        let settingButton = SBUAlertButtonItem(title: SBUStringSet.Settings) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }

        SBUAlertView.show(
            title: "Please allow microphone access.",
            message: "Permission denied.\nTo use this functionality, please allow microphone permissions on your mobile device",
            oneTimetheme: SBUTheme.componentTheme,
            confirmButtonItem: settingButton,
            cancelButtonItem: cancelButton,
            dismissHandler: completionHandler
        )
    }
}

extension SBUPhotoAccessibleStatus {
    static func from(_ authorization: PHAuthorizationStatus) -> Self {
        switch authorization {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .all
        case .limited: return .limited
        default: return .none
        }
    }
}
