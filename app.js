const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const path = require('path');
const dotenv = require('dotenv');

const app = express();
const port = 3000;

// Middleware
dotenv.config();
app.use(bodyParser.json());
app.use(express.static('public'));  // Serve static files

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch((err) => console.error('Failed to connect to MongoDB', err));

// Define ToDo model
const todoSchema = new mongoose.Schema({
  task: { type: String, required: true },
  completed: { type: Boolean, default: false }
});

const Todo = mongoose.model('Todo', todoSchema);

// API Routes

// Get all tasks
app.get('/todos', async (req, res) => {
  try {
    const todos = await Todo.find();
    res.json(todos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Add a new task
app.post('/todos', async (req, res) => {
  const { task } = req.body;

  if (!task) {
    return res.status(400).json({ error: 'Task is required' });
  }

  const newTodo = new Todo({ task });
  try {
    await newTodo.save();
    res.status(201).json(newTodo);
  } catch (err) {
    console.error('Error saving newTodo:', err);
    res.status(500).json({ error: err.message });
  }
});

// Update task (mark as completed)
app.put('/todos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTodo = await Todo.findByIdAndUpdate(id, { completed: true }, { new: true });
    if (!updatedTodo) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    res.json(updatedTodo);
  } catch (err) {
    console.error('Error updating newTodo:', err);
    res.status(500).json({ error: err.message });
  }
});

// Delete a task
app.delete('/todos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deletedTodo = await Todo.findByIdAndDelete(id);
    if (!deletedTodo) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    res.json(deletedTodo);
  } catch (err) {
    console.error('Error deleting newTodo:', err);
    res.status(500).json({ error: err.message });
  }
});

// Fibonacci Function
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// New Fibonacci endpoint
app.get('/fibonacci/:num', (req, res) => {
  const num = parseInt(req.params.num);
  if (isNaN(num) || num < 0) {
    return res.status(400).json({ error: 'Invalid number' });
  }
  const result = fibonacci(num);
  res.json({ result });
});

// Serve index.html for any unknown routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});