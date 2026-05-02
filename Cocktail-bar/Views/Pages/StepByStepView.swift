//
//  StepByStepView.swift
//  Cocktail-bar
//

import SwiftUI

// MARK: - Step-by-Step View
struct StepByStepView: View {
    @StateObject private var timerManager = CocktailTimerManager()
    @Environment(\.presentationMode) var presentationMode
    let cocktail: DrinkDetails

    var currentStepData: CocktailStep? {
        guard timerManager.currentStep < timerManager.steps.count else { return nil }
        return timerManager.steps[timerManager.currentStep]
    }

    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            VStack(spacing: 0) {
                StepHeaderView(cocktail: cocktail)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                StepProgressBar(
                    current: timerManager.currentStep + 1,
                    total: timerManager.steps.count
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                Spacer()

                if let step = currentStepData {
                    StepContentCard(step: step)
                        .padding(.horizontal, 20)
                }

                Spacer()

                if let step = currentStepData, step.duration != nil {
                    StepTimerCard(timerManager: timerManager, step: step)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }

                StepWizardNavButtons(
                    timerManager: timerManager,
                    isLastStep: timerManager.currentStep >= timerManager.steps.count - 1,
                    onFinish: { presentationMode.wrappedValue.dismiss() }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Exit")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
        }
        .onAppear { timerManager.startStepByStepMode(for: cocktail) }
        .onDisappear { timerManager.resetStepByStepMode() }
    }
}

// MARK: - Step Header
struct StepHeaderView: View {
    let cocktail: DrinkDetails

    var body: some View {
        VStack(spacing: 4) {
            Text("MAKING")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .kerning(1)
            Text(cocktail.strDrink)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(COLOR_TEXT_PRIMARY)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Step Progress Bar
struct StepProgressBar: View {
    let current: Int
    let total: Int

    var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 6)
                    Capsule()
                        .fill(COLOR_WARM_AMBER)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(height: 6)

            Text("Step \(current) of \(total)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Step Content Card
struct StepContentCard: View {
    let step: CocktailStep

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(step.isCompleted ? Color.green.opacity(0.18) : COLOR_WARM_AMBER.opacity(0.15))
                    .frame(width: 64, height: 64)
                if step.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.green)
                } else {
                    Text("\(step.stepNumber)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }

            Text(step.instruction)
                .font(.system(size: 17))
                .foregroundColor(COLOR_TEXT_PRIMARY)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(16)
    }
}

// MARK: - Step Timer Card
struct StepTimerCard: View {
    @ObservedObject var timerManager: CocktailTimerManager
    let step: CocktailStep

    var timerProgress: CGFloat {
        guard let duration = step.duration, duration > 0 else { return 0 }
        return CGFloat(timerManager.remainingTime) / CGFloat(duration)
    }

    var timerColor: Color {
        if timerManager.timerState == .completed { return .green }
        if timerManager.remainingTime <= 5 && timerManager.timerState == .running { return .red }
        return COLOR_WARM_AMBER
    }

    var body: some View {
        VStack(spacing: 20) {
            if let label = step.timerLabel {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .kerning(1)
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.10), lineWidth: 8)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(timerColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerProgress)
                Text(timerManager.formatTime(timerManager.remainingTime))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(timerColor)
            }

            HStack(spacing: 12) {
                if timerManager.timerState == .idle {
                    timerButton("Start", icon: "play.fill", bg: COLOR_WARM_AMBER, fg: .black) { timerManager.startTimer() }
                } else if timerManager.timerState == .running {
                    timerButton("Pause", icon: "pause.fill", bg: COLOR_WARM_AMBER, fg: .black) { timerManager.pauseTimer() }
                } else if timerManager.timerState == .paused {
                    timerButton("Resume", icon: "play.fill", bg: COLOR_WARM_AMBER, fg: .black) { timerManager.resumeTimer() }
                }
                if timerManager.timerState != .idle {
                    timerButton("Stop", icon: "stop.fill", bg: Color.red.opacity(0.85), fg: .white) { timerManager.stopTimer() }
                }
            }
        }
        .padding(24)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(16)
    }

    @ViewBuilder
    private func timerButton(_ label: String, icon: String, bg: Color, fg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                Text(label).font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(fg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(bg)
            .cornerRadius(12)
        }
    }
}

// MARK: - Wizard Nav Buttons
struct StepWizardNavButtons: View {
    @ObservedObject var timerManager: CocktailTimerManager
    let isLastStep: Bool
    let onFinish: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button { timerManager.previousStep() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left").font(.system(size: 13, weight: .semibold))
                    Text("Previous").font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(timerManager.currentStep == 0 ? COLOR_TEXT_SECONDARY.opacity(0.3) : COLOR_TEXT_PRIMARY)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(14)
            }
            .disabled(timerManager.currentStep == 0)

            Button { if isLastStep { onFinish() } else { timerManager.nextStep() } } label: {
                HStack(spacing: 6) {
                    Text(isLastStep ? "Finish" : "Next").font(.system(size: 15, weight: .semibold))
                    if !isLastStep { Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)) }
                }
                .foregroundColor(isLastStep ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isLastStep ? Color.green : COLOR_WARM_AMBER)
                .cornerRadius(14)
            }
        }
    }
}

// MARK: - Legacy stubs for backward compatibility
struct HeaderView: View {
    let cocktail: DrinkDetails
    var body: some View { StepHeaderView(cocktail: cocktail) }
}
struct NavigationButtons: View {
    @ObservedObject var timerManager: CocktailTimerManager
    let isLastStep: Bool
    let onFinish: () -> Void
    var body: some View { StepWizardNavButtons(timerManager: timerManager, isLastStep: isLastStep, onFinish: onFinish) }
}
