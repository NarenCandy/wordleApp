const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
dotenv.config();
const User = require('../models/user'); // Adjust the path as necessary
const router = express.Router();
router.post('/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      username,
      email,
      password: hashedPassword
    });

    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' ,
      user: {
        id: newUser._id.toString(), // This is what Flutter reads
        username: newUser.username,
        email: newUser.email
      }
    },
    
    );
  } catch (err) {
    console.error('Error in /register:', err.message);
    res.status(500).json({ message: 'Internal server error' });
  }
});


//login route
router.post('/login', async (req, res)=>{
  
  const {email , password} = req.body;
  try{
    const existingUser = await User.findOne({email})
    if(!existingUser){
      return res.status(404).json({message: "User not found"});
    }

    const isPasswordValid = await bcrypt.compare(password, existingUser.password);
    if(!isPasswordValid){
      return res.status(400).json({message: "Invalid credentials"});
    }
    const token = jwt.sign({
      id: existingUser._id,
      email: existingUser.email,
      
    }, process.env.SECRET_KEY, {
      expiresIn: process.env.JWT_EXPIRATION 
    });
    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: existingUser._id,
        email: existingUser.email,
        username: existingUser.username
      }
    });
   
  
}
  catch (err) {
    console.error('Error in /login:', err.message);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;