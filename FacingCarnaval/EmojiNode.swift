//
//  EmojiNode.swift
//  FacingCarnaval
//
//  Created by Luma Gabino Vasconcelos on 19/02/20.
//  Copyright © 2020 Luma Gabino Vasconcelos. All rights reserved.
//

import SceneKit

class EmojiNode: SCNNode {
    var option: String
    var index = 0
    
    init(with option: String , width: CGFloat = 0.05, height: CGFloat = 0.05) {
       self.option = option
       
       super.init()
       
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = option.image()
        plane.firstMaterial?.isDoubleSided = true
       
        geometry = plane
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
