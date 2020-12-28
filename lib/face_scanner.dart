import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FaceScanner extends StatefulWidget {
  @override
  _FaceScannerState createState() => _FaceScannerState();
}

class _FaceScannerState extends State<FaceScanner> {
  var _image;
  bool _isLoading;
  List<RectVO> _rectList = new List<RectVO>();
  List<DetailVO> _dvoList = new List<DetailVO>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Label Scanner')),
      body: Center(
        child: _image == null
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
                      _buildDetail(),
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

    var imgByte = await pickedImage.readAsBytes();
    _image = await decodeImageFromList(imgByte);

    setState(() {
      _isLoading = true;
    });

    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    final FaceDetector faceDetector =
        FirebaseVision.instance.faceDetector(const FaceDetectorOptions(
      enableClassification: true,
            enableTracking: true,
    ));

    final List<Face> faces = await faceDetector.processImage(visionImage);

    for (Face face in faces) {

      final double rotY =
          face.headEulerAngleY;
      final double rotZ =
          face.headEulerAngleZ;
      final double leoProb = face.leftEyeOpenProbability;
      final double reoProd = face.rightEyeOpenProbability;
final double sProb = face.smilingProbability;
      final int id = face.trackingId + 1;

      _rectList.add(new RectVO( id.toString(), face.boundingBox));


      _dvoList.add(DetailVO('Face Tracking Id', id.toString()));
      _dvoList.add(DetailVO('Euler Y angle', rotY.toStringAsFixed(2)));
      _dvoList.add(DetailVO('Euler Z angle', rotZ.toStringAsFixed(2)));
      _dvoList.add(
          DetailVO('Left eye open probability', leoProb.toStringAsFixed(2)));
      _dvoList.add(
          DetailVO('Right eye open probability', reoProd.toStringAsFixed(2)));
      _dvoList.add(DetailVO('Smiling Probability', sProb.toStringAsFixed(2)));
    }

    setState(() {
      _isLoading = false;
    });

    faceDetector.close();
  }

  Widget _buildImage() {
    return
      Column(children: [
        FittedBox(
          child: SizedBox(
            width: _image.width.toDouble(),
            height: _image.height.toDouble(),
            child: CustomPaint(
              painter: FacePainter(rect: _rectList, imageFile: _image),
            ),
          ),
        )
      ],);

  }

  Widget _buildDetail() {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Properties',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Value',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: _dvoList.map((DetailVO t) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(t.properties)),
            DataCell(Text(t.value)),
          ],
        );
      }).toList(),
    );
  }
}

class DetailVO {
  String properties;
  String value;

  DetailVO(this.properties, this.value);
}

class RectVO{
    Rect rect;
    String id;

    RectVO(this.id,this.rect);
}

class FacePainter extends CustomPainter {
  List<RectVO> rect;
  var imageFile;

  FacePainter({@required this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    for (RectVO rectangle in rect) {

      TextSpan span = new TextSpan(text: rectangle.id,style: TextStyle(fontSize:30));
      TextPainter tp = new TextPainter(text:span,textAlign: TextAlign.center,textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, rectangle.rect.center);
      canvas.drawRect(
        rectangle.rect,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke,

      );

    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
