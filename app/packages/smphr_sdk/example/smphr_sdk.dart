import 'package:smphr_sdk/smphr_sdk.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // ignore: unused_local_variable
  final semaphore =
      await Semaphore.initialize(baseUrl: 'http://192.168.1.5:5000/v1');
  // use semaphore.client
}
