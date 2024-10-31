//
//  ContentView.swift
//  vacumm2
//
//  Created by Mürşide Gökçe on 31.10.2024.
//import SwiftUI
import SwiftUI
import Foundation
import SwiftUI

// Oda durumu
enum RoomState {
    case clean
    case dirty
}

// Oda sınıfı
class Room: ObservableObject {
    @Published var state: RoomState

    init(state: RoomState = .clean) {
        self.state = state
    }
    
    func clean() {
        state = .clean
    }
    
    func makeDirty() {
        state = .dirty
    }
}

// Temizlik Robotu sınıfı
class CleaningRobot: ObservableObject {
    @Published var rooms: [Room]
    @Published var currentRoomIndex: Int = 0
    @Published var message: String = ""
    @Published var cleaningSteps: [String] = []

    init(rooms: [Room]) {
        self.rooms = rooms
    }

    func moveBetweenRooms(steps: Int) {
        cleaningSteps.removeAll() // Önceki adımları temizle
        for _ in 0..<steps {
            // Her tur için odaların durumunu güncelle
            simulateDirtiness()
            let currentRoom = rooms[currentRoomIndex]
            cleaningSteps.append("Oda \(currentRoomIndex + 1): \(currentRoom.state == .clean ? "Temiz" : "Kirli")")
            cleanCurrentRoom()
            toggleCurrentRoom()
            // Temizlik sonrası odanın durumunu tekrar kontrol et
            let nextRoom = rooms[currentRoomIndex]
            cleaningSteps.append("Oda \(currentRoomIndex + 1): \(nextRoom.state == .clean ? "Temiz" : "Kirli")")
        }
        message = "Temizlik tamamlandı!"
    }

    private func cleanCurrentRoom() {
        let currentRoom = rooms[currentRoomIndex]
        if currentRoom.state == .dirty {
            currentRoom.clean()
            message = "Oda \(currentRoomIndex + 1) temizlendi!"
        }
    }

    private func toggleCurrentRoom() {
        currentRoomIndex = (currentRoomIndex + 1) % rooms.count
    }

    func simulateDirtiness() {
        // Rastgele olarak odanın kirli ya da temiz olma durumu güncelleniyor
        for room in rooms {
            if Bool.random() {
                room.makeDirty()
            } else {
                room.clean()
            }
        }
    }
}

// Ana görünüm
struct ContentView: View {
    @StateObject var cleaningRobot = CleaningRobot(rooms: [Room(state: .dirty), Room(state: .clean)])
    @State private var steps: String = ""

    var body: some View {
        VStack {
            TextField("Temizlik Adetini Girin", text: $steps)
                .padding()
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                if let stepCount = Int(steps) {
                    cleaningRobot.moveBetweenRooms(steps: stepCount)
                }
            }) {
                Text("Temizliği Başlat")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(cleaningRobot.message)
                .padding()

            // Oda durumlarını göster
            List(cleaningRobot.cleaningSteps, id: \.self) { step in
                Text(step)
            }
            .padding(.top)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
