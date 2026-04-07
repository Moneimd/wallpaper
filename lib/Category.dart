import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:walppeper/HomePage.dart';
import 'package:walppeper/InfoPage.dart';

// Example dummy images URLs
final List<List<String>> itemBackgrounds = [
  [
    'https://picsum.photos/200/300?random=1',
    'https://picsum.photos/200/300?random=2',
    'https://picsum.photos/200/300?random=3',
  ],
  [
    'https://picsum.photos/200/300?random=4',
    'https://picsum.photos/200/300?random=5',
    'https://picsum.photos/200/300?random=6',
  ],
  [
    'https://picsum.photos/200/300?random=7',
    'https://picsum.photos/200/300?random=8',
    'https://picsum.photos/200/300?random=9',
  ],
  [
    'https://picsum.photos/200/300?random=10',
    'https://picsum.photos/200/300?random=11',
    'https://picsum.photos/200/300?random=12',
  ],
];

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int selectedIndex = 1;

  List<String> rowNames = [
    'ANIME',
    'Hero',
    'Marvel',
    'Nature',
    'Dark',
    'Cars',
    'B&W',
    'Gold',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyBroken.home, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/appbar.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text(
          'Premium',
          style: TextStyle(color: Color.fromARGB(255, 107, 52, 184)),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: rowNames.length,
                itemBuilder: (BuildContext context, int index) {
                  final int rowBackgroundIndex =
                      index % itemBackgrounds.length;
                  final List<String> rowBackgrounds =
                      itemBackgrounds[rowBackgroundIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          rowNames[index],
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      SizedBox(
                        height: 200.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: rowBackgrounds.length,
                          itemBuilder: (context, innerIndex) {
                            final String imageUrl = rowBackgrounds[innerIndex];
                            return GestureDetector(
                              onTap: () {
                                // g_ads?.interInstance.showInterstitialAd();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InfoPage(imageUrl: imageUrl)),
                                );
                              },
                              child: Container(
                                width: 150.0,
                                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error, color: Colors.red),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}