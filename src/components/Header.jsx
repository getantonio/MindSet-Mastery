struct Header: View {
    var body: some View {
        HStack {
            Image("brainShiftLogo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
    }
} 