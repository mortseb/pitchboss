import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'player_generation_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class PackOpeningPage extends StatefulWidget {
  const PackOpeningPage({Key? key}) : super(key: key);

  @override
  _PackOpeningPageState createState() => _PackOpeningPageState();
}

class _PackOpeningPageState extends State<PackOpeningPage> with RouteAware {
  int selectedIndex = 0;
  bool isPackSelected = false;

  int numberOfOrPacks = 0;
  int numberOfArgentPacks = 0;
  int numberOfBronzePacks = 0;

  Future<void> getPacksCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    final packsSnapshot = await userDoc.collection('packs').get();

    int orCount = 0;
    int argentCount = 0;
    int bronzeCount = 0;

    for (final pack in packsSnapshot.docs) {
      final packType = pack.data()['type'];

      if (packType == 'Or') {
        orCount++;
      } else if (packType == 'Argent') {
        argentCount++;
      } else if (packType == 'Bronze') {
        bronzeCount++;
      }
    }

    setState(() {
      numberOfOrPacks = orCount;
      numberOfArgentPacks = argentCount;
      numberOfBronzePacks = bronzeCount;
    });
  }

  @override
  void initState() {
    super.initState();
    getPacksCount();
  }

  void _openPack() async {
    int numberOfPlayersToGenerate;

    // Determine the number of players to generate based on the pack type (selectedIndex)
    if (selectedIndex == 0) {
      // Pack Type: Or
      numberOfPlayersToGenerate = 23;
    } else if (selectedIndex == 1) {
      // Pack Type: Argent
      numberOfPlayersToGenerate = 11;
    } else if (selectedIndex == 2) {
      // Pack Type: Bronze
      numberOfPlayersToGenerate = 5;
    } else {
      // Unknown pack type, error handling
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    // Check if the user has enough packs of the selected type
    int packCount;
    String packType;
    if (selectedIndex == 0) {
      packCount = numberOfOrPacks;
      packType = 'Or';
    } else if (selectedIndex == 1) {
      packCount = numberOfArgentPacks;
      packType = 'Argent';
    } else {
      packCount = numberOfBronzePacks;
      packType = 'Bronze';
    }

    if (packCount <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text("Vous n'avez aucun pack de ce type."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Remove a pack from the user's collection
    await userDoc
        .collection('packs')
        .where('type', isEqualTo: packType)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    // Open the player generation page
    // Open the player generation page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerGenerationPage(numberOfPlayers: numberOfPlayersToGenerate),
      ),
    );

    // Update packs count when returning from PlayerGenerationPage
    getPacksCount();
  }


  Widget _buildPackTypeWidget(String packType, int packCount, bool isSelected) {
    if (packCount <= 0) {
      return SizedBox.shrink(); // Masquer le widget si le nombre de packs est inférieur ou égal à zéro
    }

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = packType == 'Or' ? 0 : packType == 'Argent' ? 1 : 2;
          });
        },
        child: Column(
          children: [
            Image.asset(
              packType == 'Or'
                  ? 'assets/or_pack_image.png'
                  : packType == 'Argent'
                  ? 'assets/argent_pack_image.png'
                  : 'assets/bronze_pack_image.png',
              width: isSelected ? 120 : 80,
              height: isSelected ? 120 : 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              '${packType.capitalize()} Packs: $packCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                backgroundColor: packCount == 0 ? Colors.grey : null, // Ajouter un fond gris si aucun pack disponible
              ),
            ),
            const SizedBox(height: 8),
            if (isSelected)
              ElevatedButton(
                onPressed: _openPack,
                child: const Text('Ouvrir x1'),
              ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ouverture des packs'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPackTypeWidget('Or', numberOfOrPacks, selectedIndex == 0),
              const SizedBox(height: 16),
              _buildPackTypeWidget('Argent', numberOfArgentPacks, selectedIndex == 1),
              const SizedBox(height: 16),
              _buildPackTypeWidget('Bronze', numberOfBronzePacks, selectedIndex == 2),
              if (numberOfOrPacks == 0 && numberOfArgentPacks == 0 && numberOfBronzePacks == 0)
                const Text(
                  'Vous n\'avez aucun pack',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.grey,
                  ),

                ),
            ],
          ),
        ),
      ),
    );
  }  @override
  void didPopNext() {
    super.didPopNext();
    getPacksCount();
  }
}


extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}