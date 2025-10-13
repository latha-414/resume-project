const express = require('express');
const router = express.Router();

const students = [
  { id: 1, name: 'John Doe', age: 20 },
  { id: 2, name: 'Jane Smith', age: 22 }
];

router.get('/', (req, res) => {
  res.json(students);
});

router.post('/', (req, res) => {
  const newStudent = { id: students.length + 1, ...req.body };
  students.push(newStudent);
  res.status(201).json(newStudent);
});

module.exports = router;
