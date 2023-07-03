import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamRegistrationPage extends StatefulWidget {
  @override
  _TeamRegistrationPageState createState() => _TeamRegistrationPageState();
}


class _TeamRegistrationPageState extends State<TeamRegistrationPage> {
  String teamName = '';
  List<PlayerSelection> playerSelections = [];
  List<Player> players = []; // Liste des joueurs disponibles

  @override
  void initState() {
    super.initState();
    // Ajoutez ici des instances de PlayerSelection pour chaque poste
    playerSelections.add(PlayerSelection('Attaquant'));
    playerSelections.add(PlayerSelection('Attaquant'));
    playerSelections.add(PlayerSelection('Attaquant'));
    playerSelections.add(PlayerSelection('Milieu'));
    playerSelections.add(PlayerSelection('Milieu'));
    playerSelections.add(PlayerSelection('Milieu'));
    playerSelections.add(PlayerSelection('Défenseur'));
    playerSelections.add(PlayerSelection('Défenseur'));
    playerSelections.add(PlayerSelection('Défenseur'));
    playerSelections.add(PlayerSelection('Défenseur'));
    playerSelections.add(PlayerSelection('Gardien'));

    // Récupérer les joueurs depuis Firestore
    _fetchPlayers();
  }

  void _fetchPlayers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final playerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('players')
        .get();

    setState(() {
      players = playerSnapshot.docs.map((doc) => Player.fromSnapshot(doc)).toList();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enregistrer une équipe'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pitch.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nom de l\'équipe',
                ),
                onChanged: (value) {
                  setState(() {
                    teamName = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            Flexible(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                padding: EdgeInsets.all(8.0),
                children: List.generate(playerSelections.length, (index) {
                  return PlayerSelectionButton(
                    playerSelection: playerSelections[index],
                    onPlayerSelected: (player) {
                      setState(() {
                        playerSelections[index].selectedPlayer = player;
                      });
                    },
                    selectedPlayers: playerSelections
                        .where((selection) => selection.selectedPlayer != null)
                        .map((selection) => selection.selectedPlayer!)
                        .toList(),
                    players: players, // Passer la liste des joueurs ici
                  );
                }),
              ),

            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveTeam();
              },
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTeam() {
    // Vérifier si tous les joueurs ont été sélectionnés
    bool allPlayersSelected = playerSelections.every((selection) => selection.selectedPlayer != null);

    if (teamName.isEmpty || !allPlayersSelected) {
      // Afficher un message d'erreur si des champs sont vides ou des joueurs non sélectionnés
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs et sélectionner tous les joueurs.'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // L'utilisateur n'est pas connecté, affichez un message d'erreur ou demandez la connexion.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour enregistrer une équipe.'),
        ),
      );
      return;
    }

    // Enregistrer l'équipe dans Firestore
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('equipes').add({
      'nom': teamName,
      'joueurs': playerSelections.map((selection) {
        return {
          'joueurId': selection.selectedPlayer!.id,
          'poste': selection.poste,
        };
      }).toList(),
    }).then((value) {
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Équipe enregistrée avec succès.'),
        ),
      );
      // Réinitialiser les champs et la sélection des joueurs
      setState(() {
        teamName = '';
        playerSelections.forEach((selection) {
          selection.selectedPlayer = null;
        });
      });
    }).catchError((error) {
      // Afficher un message d'erreur en cas d'échec de l'enregistrement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur s\'est produite lors de l\'enregistrement de l\'équipe.'),
        ),
      );
    });
  }
}

class PlayerSelection {
  final String poste;
  Player? selectedPlayer;

  PlayerSelection(this.poste);
}

class Player {
  final String id;
  final String firstName;
  final String lastName;
  final String nationality;
  final String faceLink;
  final Map<String, int> stats;

  Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.faceLink,
    required this.stats,
  });

  factory Player.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final statsMap = data['stats'] as Map<String, dynamic>;

    final stats = statsMap.map((key, value) {
      final intValue = int.tryParse(value.toString()) ?? 0;
      return MapEntry(key, intValue);
    });

    return Player(
      id: snapshot.id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      nationality: data['nationality'],
      faceLink: data['faceLink'],
      stats: stats,
    );
  }
}

class PlayerSelectionButton extends StatelessWidget {
  final PlayerSelection playerSelection;
  final void Function(Player) onPlayerSelected;
  final List<Player> selectedPlayers;
  final List<Player> players; // Ajout de la liste des joueurs

  const PlayerSelectionButton({
    required this.playerSelection,
    required this.onPlayerSelected,
    required this.selectedPlayers,
    required this.players, // Ajout de la liste des joueurs dans le constructeur
  });

  @override
  Widget build(BuildContext context) {
    final List<Player> availablePlayers = _getAvailablePlayers();
    final bool isPlayerSelected = playerSelection.selectedPlayer != null;
    final Color backgroundColor = isPlayerSelected ? Colors.grey : Colors.white;

    return GestureDetector(
      onTap: () {
        _showPlayerSelectionDialog(context, availablePlayers);
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            SizedBox(height: 4.0),
            Text(
              playerSelection.poste,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            if (isPlayerSelected)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.asset(
                      playerSelection.selectedPlayer!.faceLink,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    _getNoteForPlayer(playerSelection.selectedPlayer!),
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showPlayerSelectionDialog(BuildContext context, List<Player> players) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // L'utilisateur n'est pas connecté, affichez un message d'erreur ou demandez la connexion.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour sélectionner un joueur.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sélectionner un joueur'),
          content: Column(
            children: [
              if (players.isNotEmpty)
                Column(
                  children: players.map((player) {
                    return ListTile(
                      title: Text('${player.firstName} ${player.lastName}'),
                      subtitle: Text('Note: ${_getNoteForPlayer(player)}'),
                      onTap: () {
                        onPlayerSelected(player);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                )
              else
                Text('Aucun joueur disponible.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  String _getNoteForPlayer(Player player) {
    final noteKey = 'note${playerSelection.poste[0].toUpperCase()}${playerSelection.poste.substring(1)}';
    final note = player.stats[noteKey];
    return note != null ? 'Note: $note' : 'Aucune note disponible';
  }

  List<Player> _getAvailablePlayers() {
    return selectedPlayers.isEmpty
        ? players
        : players.where((player) => !selectedPlayers.contains(player)).toList();
  }
}
