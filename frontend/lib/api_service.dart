import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://localhost:3000'; // Replace with your backend URL


  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }


  Future<List<dynamic>> getUserBookings(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/bookings'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user bookings');
    }
  }

Future<bool> cancelBooking(int bookingId) async {
    final url = '$baseUrl/bookings/$bookingId/cancel';
    print('[FLUTTER] Sending cancellation request to URL: $url');
    final response = await http.put(Uri.parse(url));
    print('[FLUTTER] Received response status code: ${response.statusCode}');
    return response.statusCode == 200;
}




  Future<List<dynamic>> getMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movies'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<dynamic>> getCinemas() async {
    final response = await http.get(Uri.parse('$baseUrl/cinemas'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cinemas');
    }
  }

  Future<List<dynamic>> getMoviesForCinema(int cinemaId) async {
    final response = await http.get(Uri.parse('$baseUrl/cinemas/$cinemaId/movies'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movies for cinema');
    }
  }

  Future<List<dynamic>> getShowsForMovie(int cinemaId, int movieId) async {
    final response = await http.get(Uri.parse('$baseUrl/cinemas/$cinemaId/movies/$movieId/shows'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load shows for movie');
    }
  }


  Future<Map<String, dynamic>> getSeatsForShow(int showId) async {
    final response = await http.get(Uri.parse('$baseUrl/shows/$showId/seats'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load seats for show');
    }
  }

  Future<bool> bookSeats(int userId, int showId, List<String> seats) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'showId': showId,
        'seats': seats,
      }),
    );
    return response.statusCode == 201; 
  }


} 