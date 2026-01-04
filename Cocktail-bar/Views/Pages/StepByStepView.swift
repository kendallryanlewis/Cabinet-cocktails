//
//  StepByStepView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct StepByStepView: View {
    @StateObject private var timerManager = CocktailTimerManager()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    let cocktail: DrinkDetails
    
    var currentStepData: CocktailStep? {
        guard timerManager.currentStep < timerManager.steps.count else { return nil }
        return timerManager.steps[timerManager.currentStep]
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(cocktail: cocktail)
                    .padding()
                
                // Progress
                ProgressView(current: timerManager.currentStep + 1, total: timerManager.steps.count)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Current Step
                if let step = currentStepData {
                    StepContentView(step: step)
                        .padding()
                }
                
                Spacer()
                
                // Timer Display
                if let step = currentStepData, step.duration != nil {
                    TimerDisplayView(
                        timerManager: timerManager,
                        step: step
                    )
                    .padding()
                }
                
                // Navigation Buttons
                NavigationButtons(
                    timerManager: timerManager,
                    isLastStep: timerManager.currentStep >= timerManager.steps.count - 1,
                    onFinish: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Exit")
                    }
                }
            }
        }
        .onAppear {
            timerManager.startStepByStepMode(for: cocktail)
        }
        .onDisappear {
            timerManager.resetStepByStepMode()
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let cocktail: DrinkDetails
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Making")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(cocktail.strDrink)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Progress View
struct ProgressView: View {
    let current: Int
    let total: Int
    
    var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(10)
                    
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: geometry.size.width * progress)
                        .cornerRadius(10)
                }
            }
            .frame(height: 8)
            
            // Step Counter
            Text("Step \(current) of \(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Step Content View
struct StepContentView: View {
    let step: CocktailStep
    
    var body: some View {
        VStack(spacing: 20) {
            // Step Number Badge
            ZStack {
                Circle()
                    .fill(step.isCompleted ? Color.green : Color.blue)
                    .frame(width: 60, height: 60)
                
                if step.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    Text("\(step.stepNumber)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Instruction
            Text(step.instruction)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

// MARK: - Timer Display View
struct TimerDisplayView: View {
    @ObservedObject var timerManager: CocktailTimerManager
    let step: CocktailStep
    
    var body: some View {
        VStack(spacing: 16) {
            // Timer Label
            if let label = step.timerLabel {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Timer Circle
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(timerColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerProgress)
                
                Text(timerManager.formatTime(timerManager.remainingTime))
                    .font(.displayMedium)
                    .foregroundColor(timerColor)
            }
            
            // Timer Controls
            HStack(spacing: 20) {
                if timerManager.timerState == .idle {
                    Button(action: {
                        timerManager.startTimer()
                    }) {
                        Label("Start", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                } else if timerManager.timerState == .running {
                    Button(action: {
                        timerManager.pauseTimer()
                    }) {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                } else if timerManager.timerState == .paused {
                    Button(action: {
                        timerManager.resumeTimer()
                    }) {
                        Label("Resume", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                
                if timerManager.timerState != .idle {
                    Button(action: {
                        timerManager.stopTimer()
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    var timerProgress: CGFloat {
        guard let duration = step.duration, duration > 0 else { return 0 }
        return CGFloat(timerManager.remainingTime) / CGFloat(duration)
    }
    
    var timerColor: Color {
        if timerManager.timerState == .completed {
            return .green
        } else if timerManager.remainingTime <= 5 && timerManager.timerState == .running {
            return .red
        } else {
            return .blue
        }
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    @ObservedObject var timerManager: CocktailTimerManager
    let isLastStep: Bool
    let onFinish: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Previous Button
            Button(action: {
                timerManager.previousStep()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .disabled(timerManager.currentStep == 0)
            
            // Next/Finish Button
            Button(action: {
                if isLastStep {
                    onFinish()
                } else {
                    timerManager.nextStep()
                }
            }) {
                HStack {
                    Text(isLastStep ? "Finish" : "Next")
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isLastStep ? Color.green : Color.blue)
                .cornerRadius(12)
            }
        }
    }
}
