const express = require('express');
const cors = require('cors');
const app = express();
const mongoose = require('mongoose');
const dotenv = require('dotenv');
// Adjust the path as necessary
dotenv.config();
const authRoutes = require('./routes/auth_routes'); 
const gameRoutes = require('./routes/result_routes');



app.use(express.json());
app.use(cors({
  origin: '*', // Adjust this to your frontend URL
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
app.use('/api/auth', authRoutes); // Use the auth routes

app.use('/api/game', gameRoutes);

const PORT = process.env.PORT || 3000;
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  })
  .catch(err => console.error(err));