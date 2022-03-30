alias ToDos.Item, as: ToDoItem
alias ToDos.List, as: ToDoList

pid = ToDoProcess.start()

ToDoProcess.add_entry(pid, %ToDoItem{date: ~D[2022-03-23], title: "wake up"})
ToDoProcess.add_entry(pid, %ToDoItem{date: ~D[2022-03-23], title: "drink coffee"})
ToDoProcess.add_entry(pid, %ToDoItem{date: ~D[2022-03-23], title: "drink more coffee!"})
