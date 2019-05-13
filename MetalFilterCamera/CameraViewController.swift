//
//  CameraViewController.swift
//  MetalFilterCamera
//
//  Created by gzonelee on 13/05/2019.
//  Copyright © 2019 gzonelee. All rights reserved.
//

import UIKit
import MetalKit

// Our iOS specific view controller
class CameraViewController: UIViewController {

    var session: MetalCameraSession?

    var renderer: Renderer!
    var mtkView: MTKView!
    let context = GContext()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
        
        session = MetalCameraSession(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stop()
    }
}

// MARK: - MetalCameraSessionDelegate
extension CameraViewController: MetalCameraSessionDelegate {
    func metalCameraSession(_ session: MetalCameraSession, didReceiveFrameAsTextures textures: [MTLTexture], withTimestamp timestamp: Double) {
        if UIDevice.current.orientation.isValidInterfaceOrientation {
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                renderer.deviceOrientation = UIDevice.current.orientation
            }
            else {
                if UIDevice.current.orientation.rawValue != 2 {
                    renderer.deviceOrientation = UIDevice.current.orientation
                }
            }
        }
        let ttt = textures[0]
        
        let filter = GImageFilterType.mpsUnaryImageKernel(type: .sobel).createImageFilter(context: context)
//        let filter = GImageFilterType.mpsUnaryImageKernel(type: .laplacian).createImageFilter(context: context)
        filter?.provider0 = SimpleTextureProvider(texture: ttt)
        renderer.colorMap = filter!.texture!
    }
    
    func metalCameraSession(_ cameraSession: MetalCameraSession, didUpdateState state: MetalCameraSessionState, error: MetalCameraSessionError?) {
        
        if error == .captureSessionRuntimeError {
            /**
             *  In this app we are going to ignore capture session runtime errors
             */
            cameraSession.start()
        }
        NSLog("Session changed state to \(state) with error: \(error?.localizedDescription ?? "None").")
    }
}

class SimpleTextureProvider: GTextureProvider {
    var texture: MTLTexture?
    
    init(texture: MTLTexture) {
        
        self.texture = texture
    }
}
