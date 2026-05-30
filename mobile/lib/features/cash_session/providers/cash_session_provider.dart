import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class CashSessionState {
  final Map<String, dynamic>? activeSession;
  final bool isLoading;
  final String? error;

  CashSessionState({
    this.activeSession,
    this.isLoading = false,
    this.error,
  });

  bool get isOpen => activeSession != null && activeSession!['status'] == 'open';

  CashSessionState copyWith({
    Map<String, dynamic>? activeSession,
    bool clearActiveSession = false,
    bool? isLoading,
    String? error,
  }) {
    return CashSessionState(
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CashSessionNotifier extends StateNotifier<CashSessionState> {
  final Ref ref;

  CashSessionNotifier(this.ref) : super(CashSessionState()) {
    checkActiveSession();
  }

  Future<void> checkActiveSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/cash-sessions/current');
      
      // If session exists, response is successful
      if (response.data != null) {
        state = state.copyWith(
          activeSession: response.data as Map<String, dynamic>,
          isLoading: false,
        );
      } else {
        state = state.copyWith(clearActiveSession: true, isLoading: false);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404 || e.response?.data?['error'] != null) {
        // Bad request / Not found - no active session
        state = state.copyWith(clearActiveSession: true, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Gagal memuat status kasir: ${e.message}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan sistem.',
      );
    }
  }

  Future<bool> openSession(double openingCash) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/cash-sessions/open', data: {
        'opening_cash': openingCash,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          activeSession: response.data as Map<String, dynamic>,
          isLoading: false,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] ?? 'Gagal membuka kasir.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Kesalahan sistem saat membuka kas.');
      return false;
    }
  }

  Future<Map<String, dynamic>?> closeSession(double closingCash) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/cash-sessions/close', data: {
        'closing_cash': closingCash,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final closedSession = response.data as Map<String, dynamic>;
        state = state.copyWith(clearActiveSession: true, isLoading: false);
        return closedSession;
      }
      state = state.copyWith(isLoading: false);
      return null;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] ?? 'Gagal menutup kasir.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Kesalahan sistem saat menutup kas.');
      return null;
    }
  }
}

final cashSessionProvider = StateNotifierProvider<CashSessionNotifier, CashSessionState>((ref) {
  return CashSessionNotifier(ref);
});

final cashSessionHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/cash-sessions/history');
  return response.data['data'] as List<dynamic>;
});
