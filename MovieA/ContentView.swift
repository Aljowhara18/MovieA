//
//  ContentView.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//
import SwiftUI
/*
struct ContentView: View {
    var body: some View {
        // نقوم باستدعاء صفحة تفاصيل الفيلم وتمرير الـ ViewModel لها
        // ملاحظة: مررنا ID تجريبي لأن الـ ViewModel عندك يختار فيلم عشوائي إذا لم يجد الـ ID
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "rec123456789"))
    }
}

#Preview {
    MoviesCenter()
        .preferredColorScheme(.dark)
}
*/
import SwiftUI

struct ContentView: View {
    var body: some View {
        MoviesCenter()
    }
}

#Preview {
    MoviesCenter()
        .preferredColorScheme(.dark)
}

