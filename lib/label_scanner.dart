import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LabelScanner extends StatefulWidget {
  @override
  _LabelScannerState createState() => _LabelScannerState();
}

class _LabelScannerState extends State<LabelScanner> {
  File _imageFile;
  bool _isLoading;

  List<TextObject> _textList = new List<TextObject>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Label Scanner')),
      body: Center(
        child: _imageFile == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text('Camera'),
                    onPressed: () => _getImage('camera'),
                  ),
                  ElevatedButton(
                    child: Text('Gallery'),
                    onPressed: () => _getImage('gallery'),
                  ),
                ],
              )
            : _isLoading
                ? Text('Loading...')
                : ListView(
                    children: [
                      _buildImage(),
                      _buildLabel(),
                    ],
                  ),
      ),
    );
  }

  Future<void> _getImage(String type) async {
    final picker = ImagePicker();
    PickedFile pickedImage;

    if (type == 'camera') {
      pickedImage = await picker.getImage(source: ImageSource.camera);
    } else {
      pickedImage = await picker.getImage(source: ImageSource.gallery);
    }
    File imageFile = File(pickedImage.path);
    setState(() {
      _isLoading = true;
      _imageFile = imageFile;
    });

    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);

    final ImageLabeler imgLabeler = FirebaseVision.instance.imageLabeler();

    final List<ImageLabel> labels = await imgLabeler.processImage(visionImage);

    List<TextObject> textList = new List<TextObject>();

    for (ImageLabel label in labels) {
      final double confidence = label.confidence;

      textList.add(new TextObject(label.text, confidence.toStringAsFixed(2)));
    }
    setState(() {
      _isLoading = false;

      _textList = textList;
    });

    imgLabeler.close();
  }

  Widget _buildLabel() {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Label',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Confidence',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: _textList.map((TextObject t) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(t.label)),
            DataCell(Text(t.confidence)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildImage() {
    // return Row(
    //   children:[ FittedBox(
    //     child: SizedBox(
    //       width: 100,
    //       height: 100,
    //       child: Image.file(_imageFile),
    //     ),
    //   ),]
    // );
    
    return Image.file(_imageFile,width: 200,height: 200, fit: BoxFit.cover);
  }
}

class TextObject {
  String label;
  String confidence;

  TextObject(this.label, this.confidence);
}
