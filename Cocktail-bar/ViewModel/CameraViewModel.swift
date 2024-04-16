//
//  CameraViewModel.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/14/23.
//

import Foundation
import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var caption: String = ""
    
    
}
