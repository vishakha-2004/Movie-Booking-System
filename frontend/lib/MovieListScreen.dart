import 'package:flutter/material.dart';
import 'api_service.dart';
import 'showListScreen.dart';

class MovieListScreen extends StatefulWidget {
  final int cinemaId;
  final String cinemaName;
  final int selectedUserId; 

  const MovieListScreen({
    super.key,
    required this.cinemaId,
    required this.cinemaName,
    required this.selectedUserId,
  });

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<dynamic>> futureMovies;

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService().getMoviesForCinema(widget.cinemaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cinemaName} Movies'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data![index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowListScreen(
                            cinemaId: widget.cinemaId,
                            movieId: movie['id'],
                            movieTitle: movie['title'],
                            // Pass the userId to the next screen
                            selectedUserId: widget.selectedUserId,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Release Year: ${movie['release_year']}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie['description'],
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No movies found at this cinema.'));
          }
        },
      ),
    );
  }
}