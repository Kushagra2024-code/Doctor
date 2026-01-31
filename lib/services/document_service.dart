import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'auth_service.dart';

/// Service for handling document and image uploads
class DocumentService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Take a photo with camera
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Pick a PDF or document file
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }

  /// Upload file to Firebase Storage
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final String path = 'medical_documents/${user.uid}/$fileName';
      final Reference ref = _storage.ref().child(path);
      
      // Upload file
      await ref.putFile(file);
      
      // Get download URL
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  /// Get file type from file path
  String getFileType(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType == null) return 'unknown';
    
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType == 'application/pdf') return 'pdf';
    if (mimeType.contains('document') || mimeType.contains('word')) return 'document';
    if (mimeType.startsWith('text/')) return 'text';
    
    return 'file';
  }

  /// Get file extension
  String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  bool isImage(String path) {
    final ext = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Read file as bytes
  Future<Uint8List?> readFileAsBytes(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }
}
