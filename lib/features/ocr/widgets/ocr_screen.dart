import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/azure_ocr_service.dart';
import '../models/result_text_model.dart';

final azureOcrService = AzureOcrService();

class Ocr extends StatelessWidget {
  const Ocr({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResultTextModel(),
      child: const Column(
        children: [
          //Hacer otro Widget aparte para el título
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Optical Character Recognition',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          DemoImages(),
          SelectImageIcons(),
          ResultTextContainer(),
        ],
      ),
    );
  }
}

class ResultTextContainer extends StatelessWidget {
  const ResultTextContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final resultText = context.watch<ResultTextModel>().resultText;

    return Column(
      children: [
        Container(
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
          child: const DisplayResult(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<ResultTextModel>().clearResult();
              },
              child: const Text('CLEAR'),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: resultText ?? ''));
              },
              child: const Text('COPY ALL'),
            ),
          ],
        ),
      ],
    );
  }
}

class DisplayResult extends StatelessWidget {
  const DisplayResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultTextModel>(
      builder: (context, model, child) {
        if (model.isLoading) {
          // Si la aplicación está cargando, muestra un CircularProgressIndicator
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.green),
            ),
          );
        } else {
          // Si la aplicación no está cargando, muestra el contenido normal
          return SingleChildScrollView(
            child: Text(
              model.resultText ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }
      },
    );
  }
}

class SelectImageIcons extends StatelessWidget {
  const SelectImageIcons({super.key});

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
            'You can use the camera or gallery to select an image.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
          ),
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

  useOcrWithDeviceImage(XFile? imageFile) async {
    if (imageFile == null) {
      return;
    }

    final File image = File(imageFile.path);
    final Uint8List imageBytes = await image.readAsBytes();
    Map<String, dynamic>? result =
        await azureOcrService.processImage(imageBytes);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        //stateful logic for button tap animation
        XFile? image = await onTap!();
        if (context.mounted) context.read<ResultTextModel>().setLoading();
        final Map<String, dynamic>? resultText =
            await useOcrWithDeviceImage(image);
        if (context.mounted) {
          context.read<ResultTextModel>().setResult(resultText);
        }
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
  const DemoImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            'Here are some sample images you can try (Tap):',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
          ),
        ),
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

  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showAdaptiveDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Do you want to analyze this image?'),
            actions: [
              TextButton(
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Confirm',
                    style: TextStyle(color: Color.fromARGB(255, 96, 170, 47))),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false; // Devuelve false si el usuario cierra el diálogo sin seleccionar ninguna opción
  }

  Future<Map<String, dynamic>?> useOcrWithAssetsImage() async {
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List imageBytes = bytes.buffer.asUint8List();

    Map<String, dynamic>? result;
    result = await azureOcrService.processImage(imageBytes);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showConfirmationDialog(context);
        if (!confirmed) {
          return;
        }
        if (context.mounted) {
          context.read<ResultTextModel>().setLoading();
        }
        final Map<String, dynamic>? resultText = await useOcrWithAssetsImage();
        if (context.mounted) {
          context.read<ResultTextModel>().setResult(resultText);
        }
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
