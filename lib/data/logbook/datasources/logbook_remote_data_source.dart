import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/logbook/entities/logbook_entity.dart';
import '../models/logbook_model.dart';

abstract class LogbookRemoteDataSource {
  Future<bool>              checkConnectivity();
  Future<String>            uploadLogbook(LogbookEntity logbook, String token);
  Future<List<LogbookModel>> fetchLogbooks(String token, {int page, int limit});
}

/// Lưu trữ nhật ký hiện trường lên Supabase & upload ảnh lên Supabase Storage
class LogbookRemoteDataSourceImpl implements LogbookRemoteDataSource {
  final SupabaseClient supabase;

  LogbookRemoteDataSourceImpl({
    SupabaseClient? supabaseClient,
  }) : supabase = supabaseClient ?? Supabase.instance.client;

  @override
  Future<bool> checkConnectivity() async {
    try {
      final res = await InternetAddress.lookup('google.com');
      return res.isNotEmpty && res[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> uploadLogbook(LogbookEntity logbook, String token) async {
    try {
      final imageUrls = <String>[];

      // 1. Tải ảnh lên Supabase Storage nếu có ảnh thực tế
      for (var i = 0; i < logbook.imagePaths.length; i++) {
        final path = logbook.imagePaths[i];
        final file = File(path);
        if (await file.exists()) {
          final fileName = 'field_${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg';
          
          await supabase.storage.from('logbooks').upload(
            fileName,
            file,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
          
          final downloadUrl = supabase.storage.from('logbooks').getPublicUrl(fileName);
          imageUrls.add(downloadUrl);
        }
      }

      // 2. Lưu thông tin nhật ký lên Supabase Postgres
      final String id = (logbook.id != null && logbook.id!.isNotEmpty) ? logbook.id! : 'LOG-${DateTime.now().millisecondsSinceEpoch}';
      
      // Tìm tên dự án từ mã dự án (hoặc dùng mặc định nếu không khớp)
      String projectName = logbook.projectId ?? 'Lam Dong Project 02';
      if (logbook.projectId != null) {
        try {
          final projRes = await supabase
              .from('projects')
              .select('name')
              .eq('code', logbook.projectId!)
              .maybeSingle();
          if (projRes != null && projRes['name'] != null) {
            projectName = projRes['name'] as String;
          }
        } catch (_) {}
      }

      final payload = {
        'id': id,
        // Fields for Web Dashboard:
        'date': logbook.timestamp.toIso8601String().split('T')[0],
        'type': logbook.jobType.apiValue == 'planting' ? 'Trồng cây'
              : logbook.jobType.apiValue == 'care' ? 'Chăm sóc cây'
              : logbook.jobType.apiValue == 'patrol' ? 'Tuần tra'
              : logbook.jobType.apiValue == 'fire_prev' ? 'Phòng cháy chữa cháy'
              : 'Kiểm tra sinh trưởng',
        'user': logbook.userName,
        'project': projectName,
        'location': 'Hiện trường',
        'lat': logbook.latitude,
        'lng': logbook.longitude,
        'photos': imageUrls.length,
        'desc': logbook.description,
        'synced': true,
        'images': imageUrls,

        // Fields for Flutter Mobile App:
        'job_type': logbook.jobType.apiValue,
        'description': logbook.description,
        'latitude': logbook.latitude,
        'longitude': logbook.longitude,
        'timestamp': logbook.timestamp.toIso8601String(),
        'user_id': logbook.userId,
        'user_name': logbook.userName,
        'project_id': logbook.projectId,
      };

      await supabase.from('logbooks').upsert(payload);
      return id;
    } catch (e) {
      throw ServerFailure(message: 'Lỗi đồng bộ nhật ký hiện trường: ${e.toString()}');
    }
  }

  @override
  Future<List<LogbookModel>> fetchLogbooks(String token,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await supabase
          .from('logbooks')
          .select()
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List).map((data) {
        final Map<String, dynamic> row = Map<String, dynamic>.from(data);
        row['server_id'] = row['id'];
        return LogbookModel.fromApiJson(row);
      }).toList();
    } catch (e) {
      throw ServerFailure(message: 'Lỗi tải danh sách nhật ký: ${e.toString()}');
    }
  }
}

/// MOCK — không cần backend thật để test luồng Offline/Online
class LogbookRemoteDataSourceMock implements LogbookRemoteDataSource {
  bool forceOffline;
  LogbookRemoteDataSourceMock({this.forceOffline = false});

  @override
  Future<bool> checkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return !forceOffline;
  }

  @override
  Future<String> uploadLogbook(LogbookEntity logbook, String token) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (forceOffline) throw const NetworkFailure();
    return 'SRV-LOG-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<List<LogbookModel>> fetchLogbooks(String token,
      {int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }
}
