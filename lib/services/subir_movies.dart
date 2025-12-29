
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto_netflix/data/movies_data.dart';


final DatabaseReference dbRef =
    FirebaseDatabase.instance.ref("movies");

Future<void> uploadMovies() async {
  for (var category in moviesData.keys) {
    for (var movie in moviesData[category]!) {
      await dbRef.child(category).push().set(movie);
    }
  }
}
