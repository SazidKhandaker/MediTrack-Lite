import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> uploadToCloudinary() async {
  final picker = ImagePicker();

  final pickedFile = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 60,
  );

  if (pickedFile == null) return null;

  File file = File(pickedFile.path);

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/duon0wkfh/image/upload'),
    );

    request.fields['upload_preset'] = 'meditrack_upload';

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(res.body);

      String imageUrl = data['secure_url'];

      print("Uploaded: $imageUrl");

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePhotoURL(imageUrl);
        await user.reload();
      }

      return imageUrl; // ✅ correct return
    } else {
      print("Upload failed: ${res.body}");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}