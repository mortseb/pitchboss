import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaceGenerator {
  static final random = Random();

  // Nombre total de variantes pour chaque partie du visage
  static const int totalHeads = 6;
  static const int totalEyebrows = 3;
  static const int totalEyes = 4;
  static const int totalMouths = 4;
  static const int totalNoses = 4;

  static String getFaceLink(int index) {
    return 'assets/face/head/$index.png';
  }

  static String getEyebrowsLink(int index) {
    return 'assets/face/eyebrows/$index.png';
  }

  static String getEyesLink(int index) {
    return 'assets/face/eyes/$index.png';
  }

  static String getMouthLink(int index) {
    return 'assets/face/mouth/$index.png';
  }

  static String getNoseLink(int index) {
    return 'assets/face/nose/$index.png';
  }

  static int getRandomIndex(int totalVariants) {
    return random.nextInt(totalVariants) + 1;
  }

  static String generateRandomNationality() {
    final faker = Faker();
    return faker.address.country();
  }

  static String generateRandomName() {
    final faker = Faker();
    return faker.person.firstName();
  }

  static int generateRandomStat() {
    final rand = Random();
    final probability = rand.nextDouble();

    if (probability <= 0.15) {
      // 15% de chance d'avoir entre 0 et 4
      return rand.nextInt(5);
    } else if (probability <= 0.35) {
      // 20% de chance d'avoir entre 4 et 8
      return rand.nextInt(5) + 4;
    } else if (probability <= 0.8) {
      // 45% de chance d'avoir entre 8 et 12
      return rand.nextInt(5) + 8;
    } else if (probability <= 0.95) {
      // 15% de chance d'avoir entre 12 et 16
      return rand.nextInt(5) + 12;
    } else {
      // 5% de chance d'avoir entre 16 et 20
      return rand.nextInt(5) + 16;
    }
  }

  static Map<String, dynamic> generateRandomStats() {
    final stats = {
      'sauvetage': generateRandomStat(),
      'réflexes': generateRandomStat(),
      'anticipation': generateRandomStat(),
      'dégagement': generateRandomStat(),
      'prise de balle': generateRandomStat(),
      'interception': generateRandomStat(),
      'blocage': generateRandomStat(),
      'récupération': generateRandomStat(),
      'marquage': generateRandomStat(),
      'résistance': generateRandomStat(),
      'créativité': generateRandomStat(),
      'passe précise': generateRandomStat(),
      'contrôle de balle': generateRandomStat(),
      'endurance': generateRandomStat(),
      'vision de jeu': generateRandomStat(),
      'finition': generateRandomStat(),
      'accélération': generateRandomStat(),
      'dribble': generateRandomStat(),
      'puissance de tir': generateRandomStat(),
      'positionnement': generateRandomStat(),
      'évolution': Random().nextInt(20) + 1,
      'nationality': generateRandomNationality(),
    };

    // Calculate position scores
    final goalkeeperScore = calculateGoalkeeperScore(stats);
    final defenderScore = calculateDefenderScore(stats);
    final midfielderScore = calculateMidfielderScore(stats);
    final strikerScore = calculateStrikerScore(stats);
    final totalScore = (goalkeeperScore + defenderScore + midfielderScore + strikerScore) / 4;

    // Add position scores to the stats map
    stats['noteGardien'] = goalkeeperScore;
    stats['noteDefenseur'] = defenderScore;
    stats['noteMilieu'] = midfielderScore;
    stats['noteAttaquant'] = strikerScore;
    stats['totalScore'] = totalScore.round();

    return stats;
  }

  static int calculateGoalkeeperScore(Map<String, dynamic> stats) {
    return ((stats['sauvetage'] +
        stats['réflexes'] +
        stats['anticipation'] +
        stats['dégagement'] +
        stats['prise de balle']))
        .round();
  }

  static int calculateDefenderScore(Map<String, dynamic> stats) {
    return ((stats['interception'] +
        stats['blocage'] +
        stats['récupération'] +
        stats['marquage'] +
        stats['résistance']))
        .round();
  }

  static int calculateMidfielderScore(Map<String, dynamic> stats) {
    return ((stats['créativité'] +
        stats['passe précise'] +
        stats['contrôle de balle'] +
        stats['endurance'] +
        stats['vision de jeu']))
        .round();
  }

  static int calculateStrikerScore(Map<String, dynamic> stats) {
    return ((stats['finition'] +
        stats['accélération'] +
        stats['dribble'] +
        stats['puissance de tir'] +
        stats['positionnement']))
        .round();
  }
}

class PlayerCardMiniature extends StatelessWidget {
  final Map<String, dynamic> playerData;

  PlayerCardMiniature({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final stats = playerData['stats'];
    final faceLink = playerData['faceLink'];
    final eyebrowsLink = playerData['eyebrowsLink'];
    final eyesLink = playerData['eyesLink'];
    final mouthLink = playerData['mouthLink'];
    final noseLink = playerData['noseLink'];
    final goalkeeperScore = stats['noteGardien'];
    final defenderScore = stats['noteDefenseur'];
    final midfielderScore = stats['noteMilieu'];
    final strikerScore = stats['noteAttaquant'];
    final totalScore = stats['totalScore'];
    final firstName = playerData['firstName'];
    final lastName = playerData['lastName'];

    Color getColorForScore(int score) {
      if (score >= 0 && score <= 9) {
        return Colors.black;
      } else if (score >= 10 && score <= 29) {
        return Colors.red;
      } else if (score >= 30 && score <= 39) {
        return Colors.orange;
      } else if (score >= 40 && score <= 49) {
        return Colors.yellow;
      } else if (score >= 50 && score <= 59) {
        return Colors.lightGreen;
      } else if (score >= 60 && score <= 74) {
        return Colors.green;
      } else {
        return Colors.greenAccent;
      }
    }

    return GestureDetector(
      onTap: () {
        _showPlayerDetails(context);
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visage du joueur
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      faceLink,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      eyebrowsLink,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      eyesLink,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      mouthLink,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      noseLink,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            // Notes des postes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: getColorForScore(goalkeeperScore),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Text(
                            'G',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            goalkeeperScore.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: getColorForScore(defenderScore),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Text(
                            'D',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            defenderScore.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: getColorForScore(midfielderScore),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Text(
                            'M',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            midfielderScore.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: getColorForScore(strikerScore),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            strikerScore.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Total Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: getColorForScore(totalScore),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          totalScore.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Nom du joueur
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PlayerCardDetails(playerData: playerData),
        );
      },
    );
  }
}

class PlayerCardDetails extends StatelessWidget {
  final Map<String, dynamic> playerData;

  PlayerCardDetails({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final firstName = playerData['firstName'];
    final lastName = playerData['lastName'];
    final nationality = playerData['nationality'];
    final goalkeeperScore = playerData['stats']['noteGardien'];
    final defenderScore = playerData['stats']['noteDefenseur'];
    final midfielderScore = playerData['stats']['noteMilieu'];
    final strikerScore = playerData['stats']['noteAttaquant'];
    final totalScore = playerData['stats']['totalScore'];

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName $lastName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nationality,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 16),
            // Visage du joueur
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    playerData['faceLink'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    playerData['eyebrowsLink'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    playerData['eyesLink'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    playerData['mouthLink'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    playerData['noseLink'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Statistiques détaillées
            Center(
              child: Column(
                children: [
                  buildPositionTable(context, 'Gardien', goalkeeperScore),
                  buildPositionTable(context, 'Défenseur', defenderScore),
                  buildPositionTable(context, 'Milieu', midfielderScore),
                  buildPositionTable(context, 'Attaquant', strikerScore),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Total Score
            Center(
              child: buildPositionTable(context, 'Total', totalScore),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPositionTable(BuildContext context, String position, int score) {
    Color getColorForScore(int score) {
      if (score >= 0 && score <= 9) {
        return Colors.black;
      } else if (score >= 10 && score <= 29) {
        return Colors.red;
      } else if (score >= 30 && score <= 39) {
        return Colors.orange;
      } else if (score >= 40 && score <= 49) {
        return Colors.yellow;
      } else if (score >= 50 && score <= 59) {
        return Colors.lightGreen;
      } else if (score >= 60 && score <= 74) {
        return Colors.green;
      } else {
        return Colors.greenAccent;
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                position,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getColorForScore(score),
                ),
                child: Center(
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlayerGenerationPage extends StatelessWidget {
  final int numberOfPlayers;

  PlayerGenerationPage({required this.numberOfPlayers});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> playersData = [];

    for (int i = 0; i < numberOfPlayers; i++) {
      final stats = FaceGenerator.generateRandomStats();
      final playerData = {
        'stats': stats,
        'faceLink': FaceGenerator.getFaceLink(FaceGenerator.getRandomIndex(FaceGenerator.totalHeads)),
        'eyebrowsLink': FaceGenerator.getEyebrowsLink(FaceGenerator.getRandomIndex(FaceGenerator.totalEyebrows)),
        'eyesLink': FaceGenerator.getEyesLink(FaceGenerator.getRandomIndex(FaceGenerator.totalEyes)),
        'mouthLink': FaceGenerator.getMouthLink(FaceGenerator.getRandomIndex(FaceGenerator.totalMouths)),
        'noseLink': FaceGenerator.getNoseLink(FaceGenerator.getRandomIndex(FaceGenerator.totalNoses)),
        'firstName': FaceGenerator.generateRandomName(),
        'lastName': FaceGenerator.generateRandomName(),
        'nationality': stats['nationality'],
      };

      // Envoyer le joueur en base de données
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final playersCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('players');
        playersCollection.add(playerData);
      }

      playersData.add(playerData);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Génération de joueurs'),
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        children: List.generate(playersData.length, (index) {
          final playerData = playersData[index];
          return PlayerCardMiniature(playerData: playerData);
        }),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PlayerGenerationPage(numberOfPlayers: 6),
  ));
}
