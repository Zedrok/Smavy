import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageProvider {
  Future<TaskSnapshot> uploadFile(PickedFile file) async {
    String name = UniqueKey().toString();

    Reference ref =
        FirebaseStorage.instance.ref().child('images').child('/$name');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    UploadTask uploadTask = ref.putFile(File(file.path), metadata);

    return uploadTask;
  }
}
