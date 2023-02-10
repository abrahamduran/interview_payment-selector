// Your task is to finish this application to satisfy requirements below and make it look like on the attached screenshots. Try to use 80/20 principle.
// Good luck! 🍀

// ✅ 1. Setup UI of the ContentView. Try to keep it as similar as possible.
// ✅ 2. Subscribe to the timer and count seconds down from 60 to 0 on the ContentView.
// ✅ 3. Present PaymentModalView as a sheet after tapping on the "Open payment" button.
// ✅ 4. Load payment types from repository in PaymentInfoView. Show loader when waiting for the response. No need to handle error.
// 5. List should be refreshable.
// ✅ 6. Show search bar for the list to filter payment types. You can filter items in any way.
// 7. User should select one of the types on the list. Show checkmark next to the name when item is selected.
// 8. Show "Done" button in navigation bar only if payment type is selected. Tapping this button should hide the modal.
// 9. Show "Finish" button on ContentScreen only when "payment type" was selected.
// 10. Replace main view with "FinishView" when user taps on the "Finish" button.

import SwiftUI
import Combine

class Model: ObservableObject {
    @Published var processDurationInSeconds: Int = 60
    var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
    var cancellables: [AnyCancellable] = []

    init() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      self.processDurationInSeconds > .zero
                else { return }
                
                self.processDurationInSeconds -= 1
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @StateObject private var model = Model()
    @State private var presentPaymentView = false
    
    var body: some View {
        ZStack {
            background
            content
        }
        .sheet(
            isPresented: $presentPaymentView,
            content: PaymentModalView.init
        )
    }
    
    private var content: some View {
        VStack {
            Spacer()
            
            // Seconds should count down from 60 to 0
            Text("You have only \(model.processDurationInSeconds) seconds left to get the discount")
                .foregroundColor(.white)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Spacer()
            
            Button(action: {
                presentPaymentView.toggle()
            }) {
                Text("Open payment")
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .cornerRadius(16)
                )
            }

            // Visible only if payment type is selected
            Button(action: {}) {
                Text("Finish")
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .cornerRadius(16)
                )
            }
            .hidden()
        }
        .padding(.horizontal)
    }
    
    private var background: some View {
        Color.blue.ignoresSafeArea()
    }
}

struct FinishView: View {
    var body: some View {
        Text("Congratulations")
    }
}

struct PaymentModalView : View {
    var body: some View {
        NavigationView {
            PaymentInfoView()
        }
    }
}

final class PaymentInfoViewModel: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var paymentTypes: [PaymentType] = []
    @Published private(set) var searchResults: [PaymentType] = []
    @Published var queryString = ""
    
    init(repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()) {
        repository.getTypes { [weak self] result in
            self?.isLoading = false
            guard case let .success(types) = result else {
                return
            }
            self?.paymentTypes = types
        }
        
        configureSearch()
    }
    
    private func configureSearch() {
        $queryString
            .map { [weak self] text in
//                guard !text.isEmpty else {
//                    self?.searchResults = self?.paymentTypes ?? []
//                    return
//                }
                let types = self?.paymentTypes ?? []
                return types.filter { $0.name.contains(text) }
            }
            .assign(to: &$searchResults)
    }
}

struct PaymentInfoView: View {
    @StateObject private var model = PaymentInfoViewModel()
    
    var body: some View {
        // Load payment types when presenting the view. Repository has 2 seconds delay.
        // User should select an item.
        // Show checkmark in a selected row.
        //
        // No need to handle error.
        // Use refreshing mechanism to reload the list items.
        // Show loader before response comes.
        // Show search bar to filter payment types
        //
        // Finish button should be only available if user selected payment type.
        // Tapping on Finish button should close the modal.

        ZStack {
            content
        }
        .navigationTitle("Payment info")
        .navigationBarItems(trailing: Button("Done", action: {}))
    }
    
    @ViewBuilder
    private var content: some View {
        if model.isLoading {
            ProgressView()
        } else {
            paymentTypeList
        }
    }
    
    private var paymentTypeList: some View {
        List {
            ForEach(model.paymentTypes) { paymentType in
                Text(paymentType.name)
            }
        }
        .searchable(text: $model.queryString)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
