import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_pack.dart';

class PackSelectionPage extends StatefulWidget {
  final int credits;
  final int numberOfOrPacks;
  final int numberOfArgentPacks;
  final int numberOfBronzePacks;
  final int index;

  const PackSelectionPage({
    required this.credits,
    required this.numberOfOrPacks,
    required this.numberOfArgentPacks,
    required this.numberOfBronzePacks,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  _PackSelectionPageState createState() => _PackSelectionPageState();
}

class _PackSelectionPageState extends State<PackSelectionPage> {
  String selectedPack = '';

  void buyPack() {
    if (selectedPack.isNotEmpty) {
      int numberOfPlayers;
      int cost;
      if (selectedPack == 'Or') {
        numberOfPlayers = 23;
        cost = 6000;
      } else if (selectedPack == 'Argent') {
        numberOfPlayers = 11;
        cost = 3000;
      } else if (selectedPack == 'Bronze') {
        numberOfPlayers = 5;
        cost = 1500;
      } else {
        numberOfPlayers = 0;
        cost = 0;
      }

      final CardPack selectedCardPack = CardPack(
        type: selectedPack,
        numberOfPlayers: numberOfPlayers,
        cost: cost,
      );

      if (widget.credits >= selectedCardPack.cost) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text('Voulez-vous vraiment acheter ce pack ?'),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Acheter'),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    final currentUser = FirebaseAuth.instance.currentUser;
                    final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

                    await userDoc.collection('packs').add({
                      'type': selectedCardPack.type,
                      'numberOfPlayers': selectedCardPack.numberOfPlayers,
                      'cost': selectedCardPack.cost,
                      'timestamp': Timestamp.now(),
                    });

                    await userDoc.update({
                      'numberOfPacks': FieldValue.increment(1),
                      'credits': FieldValue.increment(-selectedCardPack.cost),
                    });

                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Crédits insuffisants'),
              content: const Text('Vous n\'avez pas assez de crédits pour acheter ce pack.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Sélection de pack'),
              content: const Text('Veuillez sélectionner un pack.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection du pack'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPack = 'Or';
                });
              },
              child: const Text('Pack Or'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPack = 'Argent';
                });
              },
              child: const Text('Pack Argent'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPack = 'Bronze';
                });
              },
              child: const Text('Pack Bronze'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: buyPack,
              child: const Text('Acheter'),
            ),
          ],
        ),
      ),
    );
  }
}