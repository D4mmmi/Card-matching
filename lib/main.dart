import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: CardMatchingGame(),
    ),
  );
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Card Matching Game')),
        body: CardGrid(),
      ),
    );
  }
}

class CardModel {
  final String frontImage;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.frontImage, this.isFaceUp = false, this.isMatched = false});
}

class GameState extends ChangeNotifier {
  List<CardModel> _cards = [];
  List<CardModel> _selectedCards = [];

  GameState() {
    _initializeGame();
  }

  List<CardModel> get cards => _cards;

  void _initializeGame() {
    List<String> images = ['assets/Junior_turtle.png', 'assets/Gru_turtle.png', 'assets/Butter_turtle.png', 'assets/Peepturtle.png']; 
    _cards = images
        .expand((image) => [
              CardModel(frontImage: image),
              CardModel(frontImage: image),
            ])
        .toList()
      ..shuffle(); 

    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (card.isFaceUp || card.isMatched || _selectedCards.length == 2) return;

    card.isFaceUp = true;
    _selectedCards.add(card);

    if (_selectedCards.length == 2) {
      _checkMatch();
    }

    notifyListeners();
  }

  void _checkMatch() async {
    if (_selectedCards[0].frontImage == _selectedCards[1].frontImage) {
      _selectedCards[0].isMatched = true;
      _selectedCards[1].isMatched = true;
    } else {
      // Delay to show the second card before flipping them back
      await Future.delayed(Duration(seconds: 1));
      _selectedCards[0].isFaceUp = false;
      _selectedCards[1].isFaceUp = false;
    }
    _selectedCards.clear();
    notifyListeners();
  }

  void resetGame() {
    _initializeGame();
  }
}

class CardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4x4 grid
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: gameState.cards.length,
          itemBuilder: (context, index) {
            final card = gameState.cards[index];
            return GestureDetector(
              onTap: () => gameState.flipCard(card),
              child: CardWidget(card: card),
            );
          },
        );
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card.isFaceUp || card.isMatched ? Colors.white : Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: card.isFaceUp || card.isMatched
            ? Image.asset(card.frontImage)
            : Container(), 
      ),
    );
  }
}
