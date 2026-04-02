import '../screens/home_screen.dart';
import '../screens/add_book_screen.dart';
import '../screens/edit_book_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static final routes = {
    '/': (context) => const SplashScreen(),
    '/home': (context) => const HomeScreen(),
    '/add': (context) => const AddBookScreen(),
    '/edit': (context) => const EditBookScreen(),
    '/detail': (context) => const BookDetailScreen(),
  };
}
