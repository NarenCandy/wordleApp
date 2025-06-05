const express = require('express');
const router = express.Router();
const Result = require('../models/result');

function normalizeDate(date) {
  const d = new Date(date);
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

// Save a game result
router.post('/save', async (req, res) => {
  try {
    const { userId, won, guesses } = req.body;

    await new Result({
      userId,
      won,
      guesses
    }).save();

    res.status(201).json({ message: 'Result saved successfully' });
  } catch (err) {
    console.error('Error in /save:', err.message);
    res.status(500).json({ message: 'Save Error' });
  }
});

// Get all stats for a user
router.get('/stats/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const results = await Result.find({ userId });
    const totalGames = results.length;
    const totalWins = results.filter(r => r.won).length;
    const winPercentage = totalGames > 0 ? Math.round((totalWins / totalGames) * 100) : 0;

    const sortedResults = results.sort((a, b) => new Date(a.date) - new Date(b.date));

    let currentStreak = 0, maxStreak = 0, tempStreak = 0;
    let lastDate = null;

    sortedResults.forEach(r => {
      if (!r.won) {
        tempStreak = 0;
        lastDate = null;
        return;
      }

      const currentDate = normalizeDate(r.date);

      if (!lastDate) {
        tempStreak = 1;
      } else {
        const oneDay = 24 * 60 * 60 * 1000;
        const diff = currentDate - lastDate;
        if (diff <= oneDay && diff >= 0) {
          tempStreak++;
        } else {
          tempStreak = 1;
        }
      }

      lastDate = currentDate;
      if (tempStreak > maxStreak) maxStreak = tempStreak;
    });

    currentStreak = tempStreak;

    res.json({
      played: totalGames,
      winPercentage,
      currentStreak,
      maxStreak
    });
  } catch (err) {
    console.error('Stats Error:', err);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
});

module.exports = router;
