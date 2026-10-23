import 'package:dio/dio.dart';

class CountryApiService {
  final Dio dio = Dio();

  Future<void> getCountries() async {
    try {
      final response = await dio.get(
        'https://api.restcountries.com/countries/v5',
        queryParameters: {
          'q':'',
        },
        options: Options(
          headers: {
            'Authorization': 'rc_live_36d322b1f3ae4072b46165ffa0e7724d',
          },
        ),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('COUNTRY RESPONSE: ${response.data}');
    } on DioException catch (e) {
      print('API ERROR: ${e.message}');
      print('ERROR RESPONSE: ${e.response?.data}');
    } catch (e) {
      print('ERROR: $e');
    }
  }
}