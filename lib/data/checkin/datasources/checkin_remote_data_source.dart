import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/checkin/entities/checkin_entity.dart';
import '../models/checkin_model.dart';

abstract class CheckinRemoteDataSource {
  Future<bool> checkConnectivity();
  Future<String> upload(CheckinEntity item, String token);
}

/// Lưu thông tin check-in hiện trường lên Supabase
class CheckinRemoteDataSourceImpl implements CheckinRemoteDataSource {
  final SupabaseClient supabase;

  CheckinRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : supabase = supabaseClient ?? Supabase.instance.client;

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
  Future<String> upload(CheckinEntity item, String token) async {
    try {
      final payload = CheckinModel.fromEntity(item).toApiJson();
      final response = await supabase
          .from('checkins')
          .insert(payload)
          .select('id')
          .single();
      return response['id'].toString();
    } catch (e) {
      throw ServerFailure(message: 'Lỗi ghi nhận check-in: ${e.toString()}');
    }
  }
}

class CheckinRemoteDataSourceMock implements CheckinRemoteDataSource {
  bool forceOffline;
  CheckinRemoteDataSourceMock({this.forceOffline=false});
  @override Future<bool> checkConnectivity() async { await Future.delayed(const Duration(milliseconds:300)); return !forceOffline; }
  @override Future<String> upload(CheckinEntity item, String token) async {
    await Future.delayed(const Duration(milliseconds:700));
    if(forceOffline) throw const NetworkFailure();
    return 'SRV-CHK-${DateTime.now().millisecondsSinceEpoch}';
  }
}
