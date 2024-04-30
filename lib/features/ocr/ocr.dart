import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter/services.dart';

class Ocr extends StatelessWidget {
  const Ocr({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              'Optical Character Recognition'),
        ),
        DemoImages(),
        SelectImageIcons(),
        ResultTextContainer(),
      ],
    );
  }
}

class ResultTextContainer extends StatefulWidget {
  const ResultTextContainer({
    super.key,
  });

  @override
  State<ResultTextContainer> createState() => _ResultTextContainerState();
}

class _ResultTextContainerState extends State<ResultTextContainer> {
  String _resultText = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: Container(
            width: 320,
            height: 350,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 5, 0, 0),
                width: 2,
              ),
            ),
            child: Text(
              _resultText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _resultText = '';
                });
              },
              child: const Text('CLEAR'),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _resultText));
              },
              child: const Text('COPY ALL'),
            ),
          ],
        ),
      ],
    );
  }
}

class SelectImageIcons extends StatelessWidget {
  const SelectImageIcons({
    super.key,
  });

  Future<XFile?> _openCamera() async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
    return pickedFile;
  }

  Future<XFile?> _openGallery() async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8.0, 8, 8.0, 3.0),
          child: Text(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              'You can use the camera or gallery to select an image. '),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWithText(
              color: const Color.fromARGB(255, 33, 219, 39),
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: _openCamera,
            ),
            const SizedBox(width: 15),
            ButtonWithText(
              color: const Color.fromARGB(255, 36, 125, 18),
              icon: Icons.image,
              label: 'Gallery',
              onTap: _openGallery,
            ),
          ],
        ),
      ],
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final Future<XFile?> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //stateful logic for button tap animation
        onTap!();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DemoImages extends StatelessWidget {
  const DemoImages({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
              'Here are some sample images you can try (Tap): '),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 70, // Adjust this to the height you need
                width: 320, // Adjust this to the width you need
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    ImageWithBorder(
                        imagePath: 'assets/demo_national_identity_card.jpg',
                        width: 100,
                        fit: BoxFit.fitHeight),
                    ImageWithBorder(
                        imagePath: 'assets/demo_postit.jpg',
                        width: 100,
                        fit: BoxFit.fitWidth),
                    ImageWithBorder(
                        imagePath: 'assets/demo_recipe.jpg',
                        width: 100,
                        fit: BoxFit.fitHeight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ImageWithBorder extends StatelessWidget {
  const ImageWithBorder({
    super.key,
    required this.imagePath,
    required this.width,
    required this.fit,
  });

  final String imagePath;
  final double width;
  final BoxFit fit;

  getImagePath() {
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add your image tap logic here
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Image.asset(
          imagePath,
          width: width,
          fit: fit,
        ),
      ),
    );
  }
}
