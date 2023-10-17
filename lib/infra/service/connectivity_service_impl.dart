import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../domain/service/iconnectivity_service.dart';

class ConnectivityServiceImpl implements IConnectivityService {
  final Dio dio;
  ConnectivityServiceImpl({required this.dio});

  @override
  Future<bool> isOnline() async {
    bool hasInternet = false;
    final ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      try {
        await Dio().get('https://youtube.com.br/').timeout(const Duration(seconds: 5));
        hasInternet = true;
        return hasInternet;
      } catch(e) {
        return hasInternet;
      }
    } else {
      return hasInternet;
    }
  }
}