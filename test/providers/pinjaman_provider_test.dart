import 'package:flutter_test/flutter_test.dart';
import 'package:pustaka_digital/providers/pinjaman_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinjamanProvider notifyListeners disposal safety', () {
    test('notifyListeners should not crash when no listeners', () {
      final provider = PinjamanProvider();
      
      // Add a listener then remove it (simulating widget dispose)
      void dummyListener() {}
      provider.addListener(dummyListener);
      provider.removeListener(dummyListener);
      
      // Should not crash
      expect(() => provider.notifyListeners(), returnsNormally);
    });

    test('notifyListeners should not crash when never had listeners', () {
      final provider = PinjamanProvider();
      
      // Never had any listener
      expect(() => provider.notifyListeners(), returnsNormally);
    });
  });
}
