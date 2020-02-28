//
//  ViewController.swift
//  FacingCarnaval
//
//  Created by Luma Gabino Vasconcelos on 19/02/20.
//  Copyright © 2020 Luma Gabino Vasconcelos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var transparentTextField: UITextField!
    
    var currentFaceAnchor: ARFaceAnchor?
    var contentNode: SCNNode?
    var selectedEmoji: String? = "😜"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        transparentTextField.delegate = self
        self.sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // AR experiences typically involve moving the device without
        // touch input for some time, so prevent auto screen dimming.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // "Reset" to run the AR session for the first time.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }


    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Error handling
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Gestures and Actions
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location: CGPoint = gesture.location(in: sceneView)

            // rootNode identifica o  toque no próprio objeto (no caso a mascara facial)
            let hit = self.sceneView.hitTest(location, options: [.rootNode : contentNode])
            
            if let firstHit = hit.first {
                let coordinates = firstHit.localCoordinates
                
                //Nao deixa adicionar no próprio nó já existente
                if firstHit.node.name == nil {
                    let emojiNode = EmojiNode(with: selectedEmoji!, width: 0.02, height: 0.02)
                    emojiNode.name = "Node"
                    self.contentNode!.addChildNode(emojiNode)
                    emojiNode.position = coordinates
                }
            }
        }
    }
    
    @IBAction func cleanButton(_ sender: Any) {
        self.contentNode!.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    @IBAction func undoButton(_ sender: Any) {
        self.contentNode?.childNodes.last?.removeFromParentNode()
    }
    
}

extension ViewController: ARSCNViewDelegate {
        
    /// - Tag: CreateARSCNFaceGeometry
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
         guard let sceneView = renderer as? ARSCNView,
             anchor is ARFaceAnchor else { return nil }
         
         #if targetEnvironment(simulator)
         #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
         #else
         let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
         let material = faceGeometry.firstMaterial!

        //Adiciona testura de grade
//        material.diffuse.contents = #imageLiteral(resourceName: "wireframeTexture") // Example texture map image.
//        material.lightingModel = .physicallyBased
        material.transparency = 0.0
         
         contentNode = SCNNode(geometry: faceGeometry)
         #endif
         return contentNode
     }
     
     /// - Tag: ARFaceGeometryUpdate
     func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
         guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
             let faceAnchor = anchor as? ARFaceAnchor
             else { return }
         
         faceGeometry.update(from: faceAnchor.geometry)
     }
}


extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        textField.resignFirstResponder()

        //Pega só o último char digitado
        textField.text = string
        print(string)
        
        //Muda o emojiTextField
        self.emojiTextField.text = textField.text
        
        //Muda o emoji a ser add na mascara
        self.selectedEmoji = textField.text
        
        return true
    }
    
    
}
