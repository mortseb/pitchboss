import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pack_selection_page.dart';
import 'pack_opening_page.dart';
import 'player_list_page.dart';
import 'team_registration_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String username = ''; // Initialize the username field
  int credits = 0;
  int numberOfOrPacks = 0;
  int numberOfArgentPacks = 0;
  int numberOfBronzePacks = 0;
  int index = 0;

  @override
  void initState() {
    super.initState();
    getCredits();
    getPacksCount();
  }

  Future<void> getCredits() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    final snapshot = await userDoc.get();

    setState(() {
      credits = snapshot.data()!['credits'] ?? 0;
      username = snapshot.data()!['username'] ?? '';
    });
  }

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

  void navigateToPackSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackSelectionPage(
          credits: credits,
          numberOfOrPacks: numberOfOrPacks,
          numberOfArgentPacks: numberOfArgentPacks,
          numberOfBronzePacks: numberOfBronzePacks,
          index: index,
        ),
      ),
    );

    if (result != null && result is bool && result) {
      getCredits(); // Rafraîchir les crédits après l'achat du pack
      getPacksCount(); // Rafraîchir le nombre de packs après l'achat du pack
    }
  }

  void navigateToPlayerList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayerListPage()),
    );
  }

  void navigateToTeamRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamRegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Crédits: $credits'),
              ),
            );
          },
          child: Tooltip(
            message: 'Crédits: $credits',
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(
                  username ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Crédits: $credits'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PackOpeningPage()),
                  );
                },
                child: const Text('Ouvrir les packs'),
              ),
              ElevatedButton(
                onPressed: navigateToPackSelection,
                child: const Text('Acheter'),
              ),
              ElevatedButton(
                onPressed: navigateToPlayerList,
                child: const Text('Voir les joueurs'),
              ),
              ElevatedButton(
                onPressed: navigateToTeamRegistration,
                child: const Text('Enregistrer une équipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
