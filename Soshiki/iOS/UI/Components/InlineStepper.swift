//
//  InlineStepper.swift
//  Soshiki
//
//  Created by Jim Phieffer on 12/31/22.
//

import SwiftUI

struct InlineStepper: View {
    @Binding var value: Double

    var lowerBound: Double
    var upperBound: Double
    var step: Double
    var allowsCustomInput: Bool

    @State var currentInput: String

    init(value: Binding<Double>, lowerBound: Double, upperBound: Double, step: Double, allowsCustomInput: Bool) {
        self._value = value
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.step = step
        self.allowsCustomInput = allowsCustomInput
        self.currentInput = value.wrappedValue.toTruncatedString()
    }

    var body: some View {
        HStack {
            Button {
                if value - step >= lowerBound {
                    value -= step
                }
            } label: {
                Image(systemName: "minus")
            }.padding(.leading)
                .foregroundColor(.secondaryLabel)
                .buttonStyle(.borderless)
            Divider()
            TextField("", text: $currentInput) {
                value = Double(currentInput) ?? value
            }.multilineTextAlignment(.center)
                .lineLimit(1)
                .onChange(of: value) { newValue in
                    currentInput = newValue.toTruncatedString()
                }
                .minimumScaleFactor(0.5)
                .allowsHitTesting(allowsCustomInput)
            Divider()
            Button {
                if value + step <= upperBound {
                    value += step
                }
            } label: {
                Image(systemName: "plus")
            }.padding(.trailing)
                .foregroundColor(.secondaryLabel)
                .buttonStyle(.borderless)
        }.frame(width: 141, height: 29)
            .background(Color(uiColor: .quaternarySystemFill))
            .cornerRadius(10)
    }
}
