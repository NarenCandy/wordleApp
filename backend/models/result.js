const mongoose = require('mongoose');

const resultSchema = new mongoose.Schema({
    userId:{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    won:{
        type: Boolean,
        required: true
    },
    guesses:{
        type: Number,
        required: true
    },
  date: {
    type: Date,
    default: Date.now
  }
    
})

module.exports = mongoose.model('Result', resultSchema);