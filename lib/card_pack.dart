import 'package:flutter/material.dart';

class CardPack {
  final String type;
  final int numberOfPlayers;
  final int cost;

  const CardPack({
    required this.type,
    required this.numberOfPlayers,
    required this.cost,
  });
}

List<CardPack> availablePacks = [
  const CardPack(type: 'Or', numberOfPlayers: 23, cost: 6000),
  const CardPack(type: 'Argent', numberOfPlayers: 11, cost: 3000),
  const CardPack(type: 'Bronze', numberOfPlayers: 5, cost: 1500),
];

CardPack? findPackByType(String type) {
  for (CardPack pack in availablePacks) {
    if (pack.type == type) {
      return pack;
    }
  }
  return null;
}


class CardPacksPage extends StatefulWidget {
  const CardPacksPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CardPacksPageState createState() => _CardPacksPageState();
}

class _CardPacksPageState extends State<CardPacksPage> {
  int credits = 10000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Packs'),
      ),
      body: ListView.builder(
        itemCount: availablePacks.length,
        itemBuilder: (context, index) {
          final pack = availablePacks[index];

          return ListTile(
            title: Text(pack.type),
            subtitle: Text('Number of Players: ${pack.numberOfPlayers}'),
            trailing: Text('Cost: ${pack.cost}'),
            onTap: () {
              if (credits >= pack.cost) {
                setState(() {
                  credits -= pack.cost;
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Achat réussi'),
                      content: Text('Vous avez acheté le pack ${pack.type}.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );

              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Crédits insuffisants'),
                      content: const Text('Vous n\'avez pas assez de crédits pour acheter ce pack.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );

              }
            },
          );
        },
      ),
    );
  }
}
