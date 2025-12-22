import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static Future<String?> uploadImage(File imageFile) async {
    print('=== CLOUDINARY SERVICE UPLOAD START ===');
    print('Cloud name: $cloudName');
    print('API Key: ${apiKey.isNotEmpty ? 'Set' : 'Not set'}');
    print('API Secret: ${apiSecret.isNotEmpty ? 'Set' : 'Not set'}');
    print('Upload preset: $uploadPreset');
    print('Image file path: ${imageFile.path}');
    print('Image file exists: ${await imageFile.exists()}');
    
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print('=== CLOUDINARY CONFIGURATION ERROR ===');
      print('Cloud name empty: ${cloudName.isEmpty}');
      print('Upload preset empty: ${uploadPreset.isEmpty}');
      return Future.error('Cloudinary configuration missing.');
    }
    
    print('Building upload URL...');
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    print('Upload URL: $url');
    
    print('Creating multipart request...');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    
    print('Request fields: ${request.fields}');
    print('Request files count: ${request.files.length}');
    
    print('Sending request to Cloudinary...');
    final response = await request.send();
    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    
    if (response.statusCode == 200) {
      print('Upload successful, reading response...');
      final resStr = await response.stream.bytesToString();
      print('Response body: $resStr');
      
      final resJson = json.decode(resStr);
      final secureUrl = resJson['secure_url'];
      print('Secure URL from response: $secureUrl');
      
      print('=== CLOUDINARY SERVICE UPLOAD SUCCESS ===');
      return secureUrl; // or resJson['public_id'] if you want to store id
    } else {
      print('=== CLOUDINARY SERVICE UPLOAD FAILED ===');
      print('Status code: ${response.statusCode}');
      final errorBody = await response.stream.bytesToString();
      print('Error response: $errorBody');
      return null;
    }
  }

  // For security, image deletion should be handled server-side.
  static Future<bool> deleteImage(String publicId) async {
    // Implement this in your backend if needed.
    return false;
  }

  // Test function to verify Cloudinary configuration
  static Future<bool> testConfiguration() async {
    print('=== CLOUDINARY CONFIGURATION TEST ===');
    print('Cloud name: $cloudName');
    print('API Key: ${apiKey.isNotEmpty ? 'Set' : 'Not set'}');
    print('API Secret: ${apiSecret.isNotEmpty ? 'Set' : 'Not set'}');
    print('Upload preset: $uploadPreset');
    
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print('❌ Configuration test failed: Missing required values');
      return false;
    }
    
    print('✅ Configuration test passed: All required values are set');
    return true;
  }
} 