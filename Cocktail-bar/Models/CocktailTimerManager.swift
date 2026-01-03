//
//  CocktailTimerManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Cocktail Step
struct CocktailStep: Identifiable, Codable {
    let id: UUID
    var stepNumber: Int
    var instruction: String
    var duration: Int? // seconds
    var timerLabel: String?
    var isCompleted: Bool
    
    init(id: UUID = UUID(), stepNumber: Int, instruction: String, duration: Int? = nil, timerLabel: String? = nil, isCompleted: Bool = false) {
        self.id = id
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.duration = duration
        self.timerLabel = timerLabel
        self.isCompleted = isCompleted
    }
}

// MARK: - Timer State
enum TimerState {
    case idle
    case running
    case paused
    case completed
}

// MARK: - Cocktail Timer Manager
@MainActor
class CocktailTimerManager: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var steps: [CocktailStep] = []
    @Published var timerState: TimerState = .idle
    @Published var remainingTime: Int = 0
    @Published var isStepByStepMode: Bool = false
    
    private var timer: Timer?
    private var timerCancellable: AnyCancellable?
    
    func parseInstructions(_ instructions: String) -> [CocktailStep] {
        let sentences = instructions.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var parsedSteps: [CocktailStep] = []
        
        for (index, sentence) in sentences.enumerated() {
            var duration: Int? = nil
            var timerLabel: String? = nil
            
            // Check for time-related keywords
            if sentence.localizedCaseInsensitiveContains("shake") {
                duration = 15 // Default shake time
                timerLabel = "Shaking"
            } else if sentence.localizedCaseInsensitiveContains("stir") {
                duration = 30 // Default stir time
                timerLabel = "Stirring"
            } else if sentence.localizedCaseInsensitiveContains("muddle") {
                duration = 10
                timerLabel = "Muddling"
            } else if sentence.localizedCaseInsensitiveContains("chill") || sentence.localizedCaseInsensitiveContains("freeze") {
                duration = 300 // 5 minutes
                timerLabel = "Chilling"
            }
            
            let step = CocktailStep(
                stepNumber: index + 1,
                instruction: sentence,
                duration: duration,
                timerLabel: timerLabel
            )
            parsedSteps.append(step)
        }
        
        return parsedSteps
    }
    
    func startStepByStepMode(for cocktail: DrinkDetails) {
        steps = parseInstructions(cocktail.strInstructions ?? "")
        currentStep = 0
        isStepByStepMode = true
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            markCurrentStepComplete()
            currentStep += 1
            stopTimer()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            steps[currentStep].isCompleted = false
            stopTimer()
        }
    }
    
    func markCurrentStepComplete() {
        if currentStep < steps.count {
            steps[currentStep].isCompleted = true
        }
    }
    
    func startTimer() {
        guard currentStep < steps.count,
              let duration = steps[currentStep].duration else { return }
        
        remainingTime = duration
        timerState = .running
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.timerCompleted()
                }
            }
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        timerState = .paused
    }
    
    func resumeTimer() {
        timerState = .running
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.timerCompleted()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerState = .idle
        remainingTime = 0
    }
    
    func timerCompleted() {
        stopTimer()
        timerState = .completed
        
        // Play haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func resetStepByStepMode() {
        stopTimer()
        steps.removeAll()
        currentStep = 0
        isStepByStepMode = false
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: "0:%02d", remainingSeconds)
        }
    }
}
