import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:js' as js;

/// Entrypoint of the application.
void main() {
  // Ensure the web view uses path-based URL strategy.
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
        title: 'View Image',
        home: const HomePage());
  }
}

/// Home page widget displaying the form, image preview, and floating action button.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>(); // Key to manage the form state.
  final _urlController =
      TextEditingController(); // Controller for the URL TextField.
  bool _isButtonEnabled = false; // Tracks whether the button is enabled.
  bool _showImage = false; // Tracks whether the image should be displayed.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Inject JavaScript functions for full-screen functionality.
    _injectFullScreenFunction();
    _injectenterFullScreenFunction();
    _injectexitFullScreenFunction();
  }

  /// Injects a toggle function for entering and exiting fullscreen mode.
  void _injectFullScreenFunction() {
    js.context['toggleFullScreen'] = () {
      if (html.document.fullscreenElement == null) {
        html.document.documentElement!.requestFullscreen();
      } else {
        html.document.exitFullscreen();
      }
    };
  }

  /// Injects a function for entering fullscreen mode.
  void _injectenterFullScreenFunction() {
    js.context['enterFullScreen'] = () {
      html.document.documentElement!.requestFullscreen();
    };
  }

  /// Injects a function for exiting fullscreen mode.
  void _injectexitFullScreenFunction() {
    js.context['exitFullScreen'] = () {
      html.document.exitFullscreen();
    };
  }

  /// Validates the form and updates the button state.
  void _validateForm() {
    setState(() {
      _isButtonEnabled = _formKey.currentState?.validate() ?? false;
    });
  }

  /// Displays the image in an HTML `<img>` element.
  void _displayImage() {
    final String imageUrl = _urlController.text.trim();

    if (imageUrl.isNotEmpty) {
      // Check if the image element already exists.
      html.ImageElement? imgElement =
          html.document.getElementById('image-element') as html.ImageElement?;
      // Create a new image element if it doesn't exist.
      if (imgElement == null) {
        imgElement = html.ImageElement()
          ..id = 'image-element'
          ..style.cursor = 'pointer'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';

        // Add a double-click event listener for toggling fullscreen mode.
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
  void dispose() {
    // Dispose the controller to release resources.
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("View Image"),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview container.
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        _showImage
                            ? HtmlElementView(viewType: 'image-view')
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
                // URL input field and submit button.
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _urlController,
                        onChanged: (value) => _validateForm(),
                        validator: (value) {
                          // Validation logic: the field cannot be empty
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty';
                          }
                          return null;
                        },
                        decoration: InputDecoration(hintText: 'Image URL'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () {
                              _displayImage();
                            }
                          : null,
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
          onPressed: () => _showContextMenu(context),
          child: Icon(Icons.add),
        ));
  }

  /// Displays a context menu dialog for fullscreen actions.
  void _showContextMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  js.context.callMethod('enterFullScreen');
                  //To Close the Menu Dialog
                  Navigator.pop(context);
                },
                child: const Text('Enter Full Screen'),
              ),
              SizedBox(
                height: 8,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  js.context.callMethod('exitFullScreen');
                  //To Close the Menu Dialog
                  Navigator.pop(context);
                },
                child: const Text('Exit Full Screen'),
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}
