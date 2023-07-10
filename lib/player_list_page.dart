import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayerListPage extends StatefulWidget {
  @override
  _PlayerListPageState createState() => _PlayerListPageState();
}

class _PlayerListPageState extends State<PlayerListPage> {
  String _sortCriteria = 'Note générale';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final playersCollection =
      FirebaseFirestore.instance.collection('users').doc(userId).collection('players');

      return Scaffold(
        appBar: AppBar(
          title: Text('Liste des joueurs'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Container(
                color: Colors.white54,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(16),
                child: DropdownButton<String>(
                  value: _sortCriteria,
                  items: [
                    'Note générale',
                    'Note gardien',
                    'Note défenseur',
                    'Note milieu',
                    'Note attaquant',
                    'Nom de famille',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortCriteria = newValue!;
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: playersCollection
                      .orderBy(FieldPath.fromString(_getOrderByField()), descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Une erreur s\'est produite');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    final players = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (BuildContext context, int index) {
                        final playerData = players[index].data() as Map<String, dynamic>;
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PlayerListItem(playerData: playerData, sortCriteria: _sortCriteria),

                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  String _getOrderByField() {
    switch (_sortCriteria) {
      case 'Note générale':
        return 'stats.totalScore';
      case 'Note gardien':
        return 'stats.noteGardien';
      case 'Note défenseur':
        return 'stats.noteDefenseur';
      case 'Note milieu':
        return 'stats.noteMilieu';
      case 'Note attaquant':
        return 'stats.noteAttaquant';
      case 'Nom de famille':
        return 'lastName';
      default:
        return 'stats.totalScore';
    }
  }
}

class PlayerListItem extends StatelessWidget {
  final Map<String, dynamic> playerData;
  final String sortCriteria;

  PlayerListItem({required this.playerData, required this.sortCriteria});

  Color getColorForScore(int score) {
    if (score >= 0 && score <= 9) {
      return Colors.black;
    } else if (score >= 10 && score <= 29) {
      return Colors.red;
    } else if (score >= 30 && score <= 39) {
      return Colors.deepOrangeAccent;
    } else if (score >= 40 && score <= 49) {
      return Colors.orange;
    } else if (score >= 50 && score <= 59) {
      return Colors.lightGreen;
    } else if (score >= 60 && score <= 74) {
      return Colors.green;
    } else {
      return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastName = playerData['lastName'];
    final stats = playerData['stats'] as Map<String, dynamic>;
    final totalScore = stats['totalScore'];
    final goalkeeperScore = stats['noteGardien'];
    final defenderScore = stats['noteDefenseur'];
    final midfielderScore = stats['noteMilieu'];
    final forwardScore = stats['noteAttaquant'];
    final faceLink = playerData['faceLink'];
    final eyebrowsLink = playerData['eyebrowsLink'];
    final eyesLink = playerData['eyesLink'];
    final mouthLink = playerData['mouthLink'];
    final noseLink = playerData['noseLink'];

    // Determine the score to display based on the sort criteria
    int displayScore;
    switch (_sortCriteria) {
      case 'Note générale':
        displayScore = totalScore;
        break;
      case 'Note gardien':
        displayScore = goalkeeperScore;
        break;
      case 'Note défenseur':
        displayScore = defenderScore;
        break;
      case 'Note milieu':
        displayScore = midfielderScore;
        break;
      case 'Note attaquant':
        displayScore = forwardScore;
        break;
      default:
        displayScore = totalScore;
    }

    return Container(
      width: 64,
      height: 128,
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(faceLink, width: 64, height: 64),
              Image.asset(eyebrowsLink, width: 64, height: 64),
              Image.asset(eyesLink, width: 64, height: 64),
              Image.asset(mouthLink, width: 64, height: 64),
              Image.asset(noseLink, width: 64, height: 64),
            ],
          ),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: getColorForScore(displayScore),
            ),
            child: Center(
              child: Text(
                '$displayScore',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PlayerListPage(),
  ));
}
