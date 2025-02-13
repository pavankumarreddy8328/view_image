import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;

/// Entrypoint of the application.
void main() {
  // Ensure the web view is set up
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: const HomePage());
  }
}

enum SampleItem { enter, exit }

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  bool _showImage = false;
  final TextEditingController _urlController = TextEditingController();
  SampleItem? selectedItem;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Inject the JavaScript for fullscreen functionality
    _injectFullScreenFunction();
    _enterFullScreenFunction();
    _exitFullScreenFunction();
  }

  void _injectFullScreenFunction() {
    js.context['toggleFullScreen'] = () {
      if (html.document.fullscreenElement == null) {
        html.document.documentElement!.requestFullscreen();
      } else {
        html.document.exitFullscreen();
      }
    };
  }

  void _enterFullScreenFunction() {
    js.context['enterFullScreen'] = () {
      
        html.document.documentElement!.requestFullscreen();
      
    };
  }

  void _exitFullScreenFunction() {
    js.context['exitFullScreen'] = () {
      
        html.document.exitFullscreen();
      
    };
  }

  void _displayImage() {
    final String imageUrl = _urlController.text.trim();

    if (imageUrl.isNotEmpty) {
      // Create or update the <img> element with the new URL
      html.ImageElement? imgElement =
          html.document.getElementById('image-element') as html.ImageElement?;
      if (imgElement == null) {
        imgElement = html.ImageElement()
          ..id = 'image-element'
          ..style.cursor = 'pointer'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';

        // Add a double-click listener for fullscreen mode
        imgElement.addEventListener('dblclick', (event) {
          js.context.callMethod('toggleFullScreen');
        });

        // Append the <img> element to the body
        html.document.body!.append(imgElement);
      }

      // Update the src attribute of the <img> element
      imgElement.src = imageUrl;

      // Register the <img> element with HtmlElementView
      ui.platformViewRegistry.registerViewFactory(
        'image-view',
        (int viewId) => html.document.getElementById('image-element')!,
      );

      setState(() {
        _showImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        _showImage
                            ? Container(
                                child: HtmlElementView(viewType: 'image-view'),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _displayImage();
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            contextMenuDialog(context);
          },
          child: Icon(Icons.add),
        )
        // CupertinoContextMenu(actions: [
        //   CupertinoContextMenuAction(child: Text('Item 1')),
        //   CupertinoContextMenuAction(child: Text('Item 2')),
        // ], child: Icon(Icons.add))
        //     FloatingActionButton(
        //   onPressed: () {},
        //   child: PopupMenuButton<SampleItem>(
        //     requestFocus: true,
        //     initialValue: selectedItem,
        //     child: Icon(Icons.add),
        //     onSelected: (SampleItem item) {
        //       setState(() {
        //         selectedItem = item;
        //       });
        //     },
        //     itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        //       const PopupMenuItem<SampleItem>(
        //           value: SampleItem.enter, child: Text('Item 1')),
        //       const PopupMenuItem<SampleItem>(
        //           value: SampleItem.exit, child: Text('Item 2')),
        //     ],
        //   ),
        // ),
        );
  }

  void contextMenuDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    onPressed: () {
                      js.context.callMethod('enterFullScreen');
                    },
                    child: Text("Enter")),
                TextButton(
                    onPressed: () {
                      js.context.callMethod('exitFullScreen');
                    },
                    child: Text("Exit")),
              ],
            ),
          );
        });
  }
}
