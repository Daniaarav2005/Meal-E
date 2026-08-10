//
//  StatCard.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

struct StatCard: View {
    
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2).bold()
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)  // fills width, aligns content left
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
