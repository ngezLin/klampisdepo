import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';

class AttendanceState {
  final List<dynamic> todayLogs;
  final bool isTodayClockedIn;
  final bool isLoading;
  final String? error;

  AttendanceState({
    this.todayLogs = const [],
    this.isTodayClockedIn = false,
    this.isLoading = false,
    this.error,
  });

  AttendanceState copyWith({
    List<dynamic>? todayLogs,
    bool? isTodayClockedIn,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceState(
      todayLogs: todayLogs ?? this.todayLogs,
      isTodayClockedIn: isTodayClockedIn ?? this.isTodayClockedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref ref;

  AttendanceNotifier(this.ref) : super(AttendanceState()) {
    checkTodayStatus();
  }

  Future<void> checkTodayStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/attendance/today');
      final logs = response.data as List<dynamic>;
      
      // Check if logged-in user has clocked in today
      // Wait, let's see if we can read the username or user_id from authState
      final auth = ref.read(authProvider);
      final hasClocked = logs.any((l) => l['User']?['username'] == auth.username);

      state = state.copyWith(
        todayLogs: logs,
        isTodayClockedIn: hasClocked,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> clockIn({required String status, required String note}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final auth = ref.read(authProvider);
      final userId = auth.userId;
      if (userId == null) {
        state = state.copyWith(isLoading: false, error: 'Sesi user tidak valid.');
        return false;
      }

      final response = await dio.post('/attendance/', data: {
        'user_id': userId,
        'status': status,
        'note': note,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isTodayClockedIn: true, isLoading: false);
        checkTodayStatus(); // Refresh today logs
        return true;
      }
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] ?? 'Gagal absensi.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Kesalahan sistem saat absensi.');
      return false;
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref);
});

final attendanceHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/attendance/history');
  return response.data as List<dynamic>;
});
