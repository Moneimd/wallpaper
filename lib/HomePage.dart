import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:walppeper/Category.dart';
import 'package:iconly/iconly.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:walppeper/InfoPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:walppeper/const.dart';
import 'package:ionicons/ionicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<String> imageUrls = [];
  List<String> anime = [];
  List<String> hero = [];
  List<String> car = [];
  int selectedCategory = 0;

  String appBarBackgroundUrl = 'assets/appbar.jpg';
  int selectedIndex = 0;
  late TabController _tabController;
  late Timer _timer;

  // URLs
  final String policyUrl = "https://sites.google.com/view/wallpaperklive/home";
  final String developerUrl = "https://apps.apple.com/us/iphone/games";
  final Uri playStoreUrl = Uri.parse(
      'https://apps.apple.com/us/iphone/games');

  @override
  void initState() {
    super.initState();
    fetchJsonData();
    _tabController = TabController(vsync: this, length: 3);

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchJsonData();
    });
  }

  // Functions for launching URLs
  Future<void> _launchPolicy() async {
    final Uri url = Uri.parse(policyUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $policyUrl';
    }
  }

  Future<void> _launchDeveloper() async {
    final Uri url = Uri.parse(developerUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $developerUrl';
    }
  }

  Future<void> _rateApp() async {
    if (!await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $playStoreUrl';
    }
  }

  void _shareApp() {
    final String shareUrl = playStoreUrl.toString();
    final String shareTitle = 'Check out this app!';
    final String shareText =
        'Hey, I found this amazing app. You should check it out: $shareUrl';

    Share.share(shareText, subject: shareTitle);
  }

  void fetchJsonData() async {
    try {
      var response = await http.get(Uri.parse(
          'https://drive.google.com/uc?export=download&id=1oiCITJisensRUS4B2MpTHgxsgmjn0N3u'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          anime = List<String>.from(data['anime']);
          hero = List<String>.from(data['hero']);
          car = List<String>.from(data['car']);
        });
      } else {
        print('Failed to fetch JSON data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyBroken.category, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(),
              ),
            );
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(appBarBackgroundUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(IconlyBroken.star, color: const Color.fromARGB(255, 15, 151, 210)),
            onPressed: _rateApp, // Google Play
          ),
          IconButton(
            icon: Icon(Ionicons.share, color: Colors.lightBlue),
            onPressed: _shareApp,
          ),
          IconButton(
            icon: Icon(IconlyLight.shield_done, color: Colors.lightBlue),
            onPressed: _launchPolicy, // Privacy Policy
          ),
         
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(
              child: Text(
                'NEW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Tab(
              child: Text(
                'TOP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Tab(
              child: Text(
                'VIP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildImageList(anime),
            _buildImageList(hero),
            _buildImageList(car),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList(List<String> urls) {
    return ListView.builder(
      itemCount: (urls.length / 3).ceil(),
      itemBuilder: (context, index) {
        final startIndex = index * 3;
        final endIndex = startIndex + 2;
        final adjustedEndIndex =
            endIndex < urls.length ? endIndex : urls.length - 1;
        final rowImages = urls.sublist(startIndex, adjustedEndIndex + 1);

        return Padding(
          padding: const EdgeInsets.all(1.0),
          child: Row(
            children: rowImages.map((url) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: InkWell(
                    onTap: () {
                      g_ads?.interInstance.showInterstitialAd();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoPage(imageUrl: url),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: AspectRatio(
                          aspectRatio: 9 / 20,
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}