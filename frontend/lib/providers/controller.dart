import 'package:flutter/material.dart';
import 'package:wordle/services/api_service.dart';
import 'package:wordle/utils/calculate_chart_stats.dart';
import 'package:wordle/utils/calculate_stats.dart';
import 'package:wordle/constants/answer_stages.dart';
import 'package:wordle/data/keys_map.dart';
import 'package:wordle/models/tile_model.dart';

class Controller extends ChangeNotifier {
  String userId;
  String _username = '';
  String get username => _username;
  bool checkline = false,
      isBackOrEnter = false,
      gameWon = false,
      notEnoughLetters = false,
      gameCompleted = false;
  String correctWord = '';
  int currentTile = 0, currentRow = 0;

  void setUserId(String id) {
    userId = id;
  }

  void setUsername(String name) {
    _username = name;
    notifyListeners();
  }

  List<TileModel> tilesEntered = [];

  Controller({required this.userId});

  setCorrectWord({required String word}) => correctWord = word;

  setKeyTapped({required String value}) {
    if (value == 'ENTER') {
      if (currentTile == 5 * (currentRow + 1)) {
        isBackOrEnter = true;
        checkWord();
      } else {
        notEnoughLetters = true;
      }
    } else if (value == 'BACK') {
      isBackOrEnter = true;
      notEnoughLetters = false;
      if (currentTile > 5 * (currentRow + 1) - 5) {
        currentTile--;
        tilesEntered.removeLast();
      }
    } else {
      isBackOrEnter = false;
      notEnoughLetters = false;
      if (currentTile < 5 * (currentRow + 1)) {
        tilesEntered.add(
            TileModel(letter: value, answerStage: AnswerStage.notAnswered));
        currentTile++;
      }
    }
    notifyListeners();
  }

  checkWord() {
    List<String> guessed = [], remainingCorrect = [];

    String guessedWord = "";
    for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
      guessed.add(tilesEntered[i].letter);
    }
    guessedWord = guessed.join();
    remainingCorrect = correctWord.characters.toList();

    if (guessedWord == correctWord) {
      for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
        tilesEntered[i].answerStage = AnswerStage.correct;
        keysMap.update(tilesEntered[i].letter, (value) => AnswerStage.correct);
      }
      gameWon = true;
      gameCompleted = true;
    } else {
      for (int i = 0; i < 5; i++) {
        if (guessedWord[i] == correctWord[i]) {
          remainingCorrect.remove(guessedWord[i]);
          tilesEntered[i + (currentRow * 5)].answerStage = AnswerStage.correct;
          keysMap.update(guessedWord[i], (value) => AnswerStage.correct);
        }
      }

      for (int i = 0; i < remainingCorrect.length; i++) {
        for (int j = 0; j < 5; j++) {
          if (remainingCorrect[i] ==
              tilesEntered[j + (currentRow * 5)].letter) {
            if (tilesEntered[j + (currentRow * 5)].answerStage !=
                AnswerStage.correct) {
              tilesEntered[j + (currentRow * 5)].answerStage =
                  AnswerStage.contains;
            }
            final resultKey = keysMap.entries.where((element) =>
                element.key == tilesEntered[j + (currentRow * 5)].letter);

            if (resultKey.single.value != AnswerStage.correct) {
              keysMap.update(
                  resultKey.single.key, (value) => AnswerStage.contains);
            }
          }
        }
      }
      for (int i = currentRow * 5; i < (currentRow * 5) + 5; i++) {
        if (tilesEntered[i].answerStage == AnswerStage.notAnswered) {
          tilesEntered[i].answerStage = AnswerStage.incorrect;
          final results = keysMap.entries
              .where((element) => element.key == tilesEntered[i].letter);
          if (results.single.value == AnswerStage.notAnswered) {
            keysMap.update(
                tilesEntered[i].letter, (value) => AnswerStage.incorrect);
          }
        }
      }
    }

    checkline = true;
    currentRow++;
    if (currentRow == 6) {
      gameCompleted = true;
    }
    if (gameCompleted == true) {
      calculateStats(gameWon: gameWon, guesses: currentRow);
      if (gameWon) {
        setChartStats(currentRow: currentRow);
      }

      int guesses = currentRow;
      ApiService.saveResult(userId: userId, won: gameWon, guesses: guesses)
          .then((success) {
        if (success) {
          print('Result saved successfully');
        } else {
          print('Failed to save result');
        }
      });
    }
    notifyListeners();
  }

  void resetGame() {
    checkline = false;
    isBackOrEnter = false;
    gameWon = false;
    notEnoughLetters = false;
    gameCompleted = false;

    currentTile = 0;
    currentRow = 0;
    tilesEntered.clear();

    correctWord = ''; // Optional: set this again from HomePage if needed

    notifyListeners();
  }
}
