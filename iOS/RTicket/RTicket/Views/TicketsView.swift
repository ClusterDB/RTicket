//
//  TicketsView.swift
//  RTicket
//
//  Created by Andrew Morgan on 25/02/2022.
//

import SwiftUI
import RealmSwift

struct TicketsView: View {
    let product: String
    let username: String
    
    @ObservedResults(Ticket.self, sortDescriptor: SortDescriptor(keyPath: "status", ascending: false)) var tickets
    @Environment(\.realm) var realm
    
    @State private var title = ""
    @State private var description = ""
    @State private var searchText = ""
    @State private var inProgress = false
    
    var body: some View {
        return ZStack {
            VStack {
                List {
                    ForEach(tickets) { ticket in
                        TicketView(ticket: ticket)
                    }
                }
                .searchable(text: $searchText)
                Spacer()
                VStack {
                    TextField("Ticket title", text: $title)
                    TextField("Ticket description", text: $description)
                    Button(action: addTicket) {
                        Text("Add Ticket")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title == "")
                }
                .padding()
            }
            if inProgress {
                ProgressView()
            }
            
        }
        .navigationBarTitle("\(product) Tickets", displayMode: .inline)
        .onAppear(perform: setSubscriptions)
        .onDisappear(perform: clearSubscriptions)
    }
    
    private func setSubscriptions() {
        let subscriptions = realm.subscriptions
        if subscriptions.first(named: product) == nil {
            print("Setting subscription for \(product)")
            inProgress = true
            subscriptions.write {
                subscriptions.append(QuerySubscription<Ticket>(name: product) { ticket in
                    ticket.product == product
                })
            }
            // TODO: This seems to be needed atm (10.22.0) so that the view is refreshed once
            // the tickets have been found
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                inProgress = false
            }
        }
    }
    
    private func clearSubscriptions() {
        let subscriptions = realm.subscriptions
        subscriptions.write {
            subscriptions.remove(named: product)
        }
    }
    
    private func addTicket() {
        let ticket = Ticket(reportedBy: username, product: product, title: title, problemDescription: description != "" ? description : nil)
        $tickets.append(ticket)
        title = ""
        description = ""
    }
}

//struct TicketsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TicketsView(product: "Realm", username: "Andrew")
//        }
//    }
//}