import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/azure_ocr_service.dart';
import '../models/result_text_model.dart';

final azureOcrService = AzureOcrService();

void showErrorAlert(BuildContext context, String message) {
  showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

bool errorResponse(Map<String, dynamic>? response) {
  if (response?['error'] != null) {
    return true;
  } else if (response?['analyzeResult']['readResults'][0]['lines'].isEmpty) {
    return true;
  }
  return false;
}

void handleErrorResponse(BuildContext context, Map<String, dynamic>? response) {
  String errorMessage;

  if (response?['error'] != null) {
    final String code = response?['error']!['code'] ?? '';
    final String messageText = response?['error']['message'] ?? '';
    errorMessage = '$code: $messageText';
  } else {
    errorMessage = 'No text detected in the image';
  }
  if (context.mounted) {
    showErrorAlert(context, errorMessage);
    context.read<ResultTextModel>().clearResult();
    context.read<ResultTextModel>().setLoading();
  }
}

class OcrScreen extends StatelessWidget {
  const OcrScreen({super.key});

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
          DemoImagesContainer(),
          SelectImageContainer(),
          ResultTextContainer(),
        ],
      ),
    );
  }
}

class ResultTextContainer extends StatefulWidget {
  const ResultTextContainer({super.key});

  @override
  State<ResultTextContainer> createState() => _ResultTextContainerState();
}

class _ResultTextContainerState extends State<ResultTextContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final resultText = context.watch<ResultTextModel>().resultText;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30.0),
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
            child: ResultInTabBar(tabController: _tabController),
          ),
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

class ResultInTabBar extends StatelessWidget {
  const ResultInTabBar({
    required this.tabController,
    super.key,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultTextModel>(
      builder: (context, model, child) {
        return model.isLoading
            ? const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.green,
                  ),
                ),
              )
            : Column(
                children: [
                  TabBar(
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Text'),
                      Tab(text: 'Image'),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBarView(
                        controller: tabController,
                        children: const [
                          DisplayResult(),
                          SelectedImage(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}

class SelectedImage extends StatelessWidget {
  const SelectedImage({super.key});

  @override
  Widget build(BuildContext context) {
    final imageData = Provider.of<ResultTextModel>(context).imageData;

    return imageData != null
        ? Image.memory(
            imageData,
            fit: BoxFit.contain,
          )
        : const SizedBox();
  }
}

class DisplayResult extends StatelessWidget {
  const DisplayResult({super.key});

  @override
  Widget build(BuildContext context) {
    final resultText = context.watch<ResultTextModel>().resultText;

    return SingleChildScrollView(
      child: Text(
        resultText ?? '',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class SelectImageContainer extends StatelessWidget {
  const SelectImageContainer({super.key});

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

  useOcrWithDeviceImage(XFile? imageFile, BuildContext context) async {
    if (imageFile == null) {
      return;
    }

    final File image = File(imageFile.path);
    final Uint8List imageBytes = await image.readAsBytes();

    Map<String, dynamic>? result =
        await azureOcrService.processImage(imageBytes);
    if (context.mounted) {
      context.read<ResultTextModel>().setImageData(imageBytes);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        //stateful logic for button tap animation
        XFile? image = await onTap!();
        if (!context.mounted) return;
        context.read<ResultTextModel>().setLoading();

        final Map<String, dynamic>? response =
            await useOcrWithDeviceImage(image, context);

        if (errorResponse(response)) {
          if (!context.mounted) return;
          handleErrorResponse(context, response);
          return;
        }

        if (!context.mounted) return;
        context.read<ResultTextModel>().setResult(response);
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

class DemoImagesContainer extends StatelessWidget {
  const DemoImagesContainer({super.key});

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
            height: 70,
            width: 320,
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
        false;
  }

  Future<Map<String, dynamic>?> useOcrWithAssetsImage(
      BuildContext context) async {
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List imageBytes = bytes.buffer.asUint8List();

    Map<String, dynamic>? result;
    result = await azureOcrService.processImage(imageBytes);

    if (context.mounted) {
      context.read<ResultTextModel>().setImageData(imageBytes);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showConfirmationDialog(context);
        if (!confirmed) return;
        if (!context.mounted) return;

        context.read<ResultTextModel>().setLoading();
        final Map<String, dynamic>? response =
            await useOcrWithAssetsImage(context);

        if (errorResponse(response)) {
          if (!context.mounted) return;
          handleErrorResponse(context, response);
          return;
        }

        if (!context.mounted) return;
        context.read<ResultTextModel>().setResult(response);
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
