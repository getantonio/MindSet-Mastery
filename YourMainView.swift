struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Header()
                // Rest of your app content
            }
            .navigationBarHidden(true)
        }
    }
} 