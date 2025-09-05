//
//  DataAtGlanceContainerSmall.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/09/06.
//

import SwiftUI

struct DataAtGlanceContainerSmall: View {
    
    var title: String
    var symbol: String
    var subtitle: String
    var color: Color

    var body: some View {
        VStack {
            mainLabelView
                .frame(width: 150)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12, style: .circular).fill(Color(.secondarySystemBackground)))
    }
    
    var mainLabelView: some View {
        VStack {
            Label(title, systemImage: symbol)
                .foregroundStyle(color)
                .frame(alignment: .leading)
            
            Text(subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    DataAtGlanceContainerSmall(title: "Body Weight", symbol: "figure", subtitle: "80 Kg", color: .indigo)
}
