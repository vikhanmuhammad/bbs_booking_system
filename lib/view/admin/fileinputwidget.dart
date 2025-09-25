import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FileInputWidget extends StatefulWidget {
  final String fileType;
  final void Function(String? firebaseUrl)? onSaveToDatabase;

  FileInputWidget({required this.fileType, this.onSaveToDatabase});

  @override
  _FileInputWidgetState createState() => _FileInputWidgetState();
}

class _FileInputWidgetState extends State<FileInputWidget> {
  String _filePath = '';
  bool _isUploading = false; // Variabel untuk mengontrol status upload

  Future<String?> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _filePath = file.path!;
        _isUploading = true; // Set status upload menjadi true
      });

      try {
        // Tentukan direktori Firebase Storage berdasarkan jenis file
        String directory = widget.fileType == 'Image' ? 'paketImg/' : 'file/';

        // Upload file ke Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child(directory)
            .child(path.basename(_filePath));
        UploadTask uploadTask = ref.putFile(File(_filePath));
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

        // Dapatkan URL file yang diupload
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Panggil callback untuk menyimpan URL ke database jika tersedia
        if (widget.onSaveToDatabase != null) {
          widget.onSaveToDatabase!(downloadUrl);
        }

        return downloadUrl;
      } finally {
        setState(() {
          _isUploading = false; // Set status upload menjadi false
        });
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.fileType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () async {
            await _pickPdfFile();
          },
          child: Row(
            children: [
              const Icon(Icons.attach_file),
              const SizedBox(width: 8),
              Text(
                'Choose ${widget.fileType}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_isUploading)
          const Center(
            child: CircularProgressIndicator(), // Indikator proses upload
          ),
        if (_filePath.isNotEmpty && !_isUploading)
          Text(
            _filePath,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }
}
