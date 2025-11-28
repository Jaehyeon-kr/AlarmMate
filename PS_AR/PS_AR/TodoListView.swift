import SwiftUI

struct TodoListView: View {
    @Binding var todos: [String]        // ← HomeView와 연결
    @State private var newTodo = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("할 일 입력", text: $newTodo)
                        .textFieldStyle(.roundedBorder)

                    Button("추가") {
                        if !newTodo.isEmpty {
                            todos.append(newTodo)   // ← HomeView와 공유됨
                            TodoRepository.shared.insert(title: newTodo)
                            newTodo = ""
                        }
                    }
                }
                .padding()

                List {
                    ForEach(todos, id: \.self) { todo in
                        Text(todo)
                    }
                    .onDelete { indexSet in
                        todos.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("할 일 목록")
        }
    }
}
