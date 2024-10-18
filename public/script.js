const apiUrl = '/todos';

document.addEventListener('DOMContentLoaded', loadTodos);

const todoForm = document.getElementById('todo-form');
const taskInput = document.getElementById('task');
const todoList = document.getElementById('todo-list');

// Load all todos when the page loads
async function loadTodos() {
  const res = await fetch(apiUrl);
  const todos = await res.json();
  todos.forEach(addTodoToList);
}

// Add new task on form submit
todoForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const task = taskInput.value;

  if (task) {
    const res = await fetch(apiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ task })
    });

    const newTodo = await res.json();
    addTodoToList(newTodo);
    taskInput.value = '';
  }
});

// Add a task to the UI
function addTodoToList(todo) {
  const li = document.createElement('li');
  li.dataset.id = todo._id;
  li.innerHTML = `
    ${todo.completed ? `<span class="completed">${todo.task}</span>` : todo.task}
    <button onclick="completeTask('${todo._id}')">Complete</button>
    <button onclick="deleteTask('${todo._id}')">Delete</button>
  `;
  todoList.appendChild(li);
}

// Complete a task
async function completeTask(id) {
  await fetch(`${apiUrl}/${id}`, {
    method: 'PUT'
  });

  const taskItem = document.querySelector(`li[data-id='${id}']`);
  taskItem.querySelector('span').classList.add('completed');
}

// Delete a task
async function deleteTask(id) {
  await fetch(`${apiUrl}/${id}`, {
    method: 'DELETE'
  });

  const taskItem = document.querySelector(`li[data-id='${id}']`);
  taskItem.remove();
}

// Fibonacci API interaction
const fibonacciForm = document.getElementById('fibonacci-form');
const fibResultDiv = document.getElementById('fibonacci-results');

// Listen to Fibonacci form submit
fibonacciForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const count = document.getElementById('fibonacci-count').value;
  const times = document.getElementById('fibonacci-times').value;

  if (count && times) {
    fibResultDiv.innerHTML = 'Calculating...';
    const results = await makeFibonacciCalls(count, times);
    fibResultDiv.innerHTML = '';
    results.forEach((result, index) => {
      const p = document.createElement('p');
      p.textContent = `Call ${index + 1}: Fibonacci(${count}) = ${result}`;
      fibResultDiv.appendChild(p);
    });
  }
});

// Make multiple asynchronous Fibonacci API calls
async function makeFibonacciCalls(count, times) {
  const promises = [];
  for (let i = 0; i < times; i++) {
    promises.push(fetch(`/fibonacci/${count}`).then(res => res.json()));
  }

  const results = await Promise.all(promises);
  return results.map(result => result.result);
}