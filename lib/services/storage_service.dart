import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadCertificate({
    required String id,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ext = fileName.split('.').last;
    final path = '$id/cert.$ext';
    
    await _supabase.storage.from('documents').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _supabase.storage.from('documents').getPublicUrl(path);
  }

  Future<String> uploadCV({
    required String uid,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ext = fileName.split('.').last;
    final path = 'cvs/$uid/cv_${DateTime.now().millisecondsSinceEpoch}.$ext';
    
    await _supabase.storage.from('documents').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    
    return _supabase.storage.from('documents').getPublicUrl(path);
  }
}