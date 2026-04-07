import 'dart:io' show Directory, File, Platform;

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:iconly/iconly.dart';
import 'package:share/share.dart';
import 'package:walppeper/const.dart';

class InfoPage extends StatefulWidget {
  final String imageUrl;

  const InfoPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool _isFullscreen = true;
  late bool goToHome;
  bool _saving = false;
  bool _wallpaperBusy = false;

  @override
  void initState() {
    goToHome = false;

    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
  }

  Future<void> _saveImageToGallery() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final bool access = await Gal.requestAccess();
      if (!access) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Allow Photos access in Settings to save images',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            textColor: const Color.fromARGB(255, 3, 207, 200),
            fontSize: 16.0,
          );
        }
        return;
      }

      Fluttertoast.showToast(
        msg: 'Saving…',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: const Color.fromARGB(255, 10, 219, 243),
        fontSize: 16.0,
      );

      final http.Response response =
          await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Could not download image',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        return;
      }

      final String name =
          'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Gal.putImageBytes(response.bodyBytes, name: name);

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Saved to Photos',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: const Color.fromARGB(255, 238, 192, 8),
          fontSize: 16.0,
        );
      }
    } on GalException catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.type.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Save failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: const Color.fromARGB(255, 210, 116, 116),
          fontSize: 16.0,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// iOS cannot set the lock/home wallpaper by API; share the image so the user
  /// can use "Save Image" / Shortcuts / Photos → "Use as Wallpaper".
  Future<void> _shareImageForWallpaperIos(BuildContext context) async {
    if (_wallpaperBusy) return;
    setState(() => _wallpaperBusy = true);
    File? temp;
    try {
      Fluttertoast.showToast(
        msg: 'Preparing image…',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Rect? shareOrigin;
      final RenderBox? anchor = context.findRenderObject() as RenderBox?;
      if (anchor != null && anchor.hasSize) {
        final topLeft = anchor.localToGlobal(Offset.zero);
        shareOrigin = topLeft & anchor.size;
      }

      final http.Response response =
          await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Could not download image',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        return;
      }

      temp = File(
        '${Directory.systemTemp.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await temp.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      await Share.shareFiles(
        [temp.path],
        mimeTypes: const ['image/jpeg'],
        text: 'Wallpaper',
        sharePositionOrigin: shareOrigin,
      );
    } catch (_) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Could not open share sheet',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } finally {
      final String? pathToRemove = temp?.path;
      if (pathToRemove != null) {
        Future<void>.delayed(const Duration(minutes: 2), () async {
          try {
            final f = File(pathToRemove);
            if (await f.exists()) await f.delete();
          } catch (_) {}
        });
      }
      if (mounted) setState(() => _wallpaperBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            if (_isFullscreen)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 64.0,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(IconlyBroken.arrow_down),
                                onPressed: _saving
                                    ? null
                                    : () async {
                                        g_ads?.interInstance
                                            .showInterstitialAd();
                                        await _saveImageToGallery();
                                      },
                                color: Colors.white,
                                iconSize: 30,
                              ),
                            ),
                            SizedBox(width: 24.0),
                            Container(
                              width: 64.0,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Builder(
                                builder: (btnContext) {
                                  return IconButton(
                                onPressed: _wallpaperBusy
                                    ? null
                                    : () async {
                                        g_ads?.interInstance
                                            .showInterstitialAd();
                                        if (Platform.isIOS) {
                                          await _shareImageForWallpaperIos(
                                              btnContext);
                                          return;
                                        }
                                        if (!Platform.isAndroid) {
                                          Fluttertoast.showToast(
                                            msg:
                                                'Wallpaper: use iOS or Android',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          return;
                                        }
                                        final WallpaperResult result =
                                            await AsyncWallpaper.setWallpaper(
                                          WallpaperRequest(
                                            target: WallpaperTarget.home,
                                            sourceType: WallpaperSourceType.url,
                                            source: widget.imageUrl,
                                            goToHome: goToHome,
                                          ),
                                        );
                                        final String message =
                                            result.isSuccess
                                                ? 'Wallpaper set'
                                                : 'Failed to get wallpaper.';
                                        Fluttertoast.showToast(
                                          msg: message,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      },
                                icon: Icon(IconlyBroken.image),
                                color: Colors.white,
                                iconSize: 30,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
