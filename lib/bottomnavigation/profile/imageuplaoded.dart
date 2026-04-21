import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> pickAndUploadImage() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final picker = ImagePicker();

  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return;

  File file = File(pickedFile.path);

  try {
    // 🔥 upload to Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${user.uid}.jpg');

    await ref.putFile(file);

    // 🔗 get download URL
    final url = await ref.getDownloadURL();

    // 👤 set Firebase Auth photoURL
    await user.updatePhotoURL(url);
    await user.reload();

    print("Photo uploaded: $url");

  } catch (e) {
    print("Upload error: $e");
  }
}