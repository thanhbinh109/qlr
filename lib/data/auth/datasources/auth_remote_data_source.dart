// FILE: lib/data/auth/datasources/auth_remote_data_source.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/failure.dart';
import '../../../domain/auth/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout(String token);
}

/// Kết nối Firestore database — xác thực thông tin trong collection `users`
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : supabase = supabaseClient ?? Supabase.instance.client;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (response == null) {
        throw const AuthFailure(message: 'Email hoặc mật khẩu không đúng.');
      }

      final userData = Map<String, dynamic>.from(response);
      
      // Đảm bảo ID và Token được cấu hình hợp lệ
      if (!userData.containsKey('id') || userData['id'] == null) {
        userData['id'] = userData['email'];
      }
      if (!userData.containsKey('token') && !userData.containsKey('accessToken')) {
        userData['token'] = 'jwt_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}';
      }
      if (!userData.containsKey('refreshToken')) {
        userData['refreshToken'] = 'refresh_${userData['id']}';
      }

      if (userData['status'] == 'locked') {
        throw const AuthFailure(message: 'Tài khoản đã bị khóa. Liên hệ quản trị viên.');
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw ServerFailure(message: 'Lỗi xác thực hệ thống: ${e.toString()}');
    }
  }

  @override
  Future<void> logout(String token) async {
    // Session local được xóa tại local storage
    return;
  }
}

// ─────────────────────────────────────────────────────────────────────────
/// MOCK — chạy demo không cần backend.
/// 3 tài khoản tương ứng 3 role, đồng bộ với seed data Web Dashboard.
// ─────────────────────────────────────────────────────────────────────────
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  static final _users = [
    {'id':'ADM-001','fullName':'Admin Platform','email':'admin@qlr.vn',
     'phone':'0900000001','role':'platform_admin','password':'123456','status':'active'},
    {'id':'OWN-001','fullName':'Nguyễn Văn A','email':'owner@qlr.vn',
     'phone':'0900000002','role':'forest_owner','password':'123456','status':'active'},
    {'id':'WKR-001','fullName':'Trần Thị B','email':'worker@qlr.vn',
     'phone':'0900000003','role':'forest_worker','password':'123456','status':'active'},
  ];

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final u = _users.firstWhere(
      (x) => x['email'] == email && x['password'] == password,
      orElse: () => {},
    );
    if (u.isEmpty) throw const AuthFailure();
    if (u['status'] == 'locked') {
      throw const AuthFailure(message: 'Tài khoản đã bị khóa. Liên hệ quản trị viên.');
    }
    return UserModel(
      id:           u['id']!,
      fullName:     u['fullName']!,
      email:        u['email']!,
      phone:        u['phone']!,
      role:         userRoleFromApi(u['role']!),
      token:        'jwt_${u['id']}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'refresh_${u['id']}',
      status:       u['status']!,
      lastLogin:    DateTime.now(),
    );
  }

  @override
  Future<void> logout(String token) async =>
    Future.delayed(const Duration(milliseconds: 150));
}
