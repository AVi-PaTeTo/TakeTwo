import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Required for SystemNavigator.pop()
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/models/user.dart';
import 'package:mobile/features/create/screens/create_screen.dart';
import 'package:mobile/features/explore/screens/explore_screen.dart';
import 'package:mobile/features/search/screens/search_screen.dart';
import 'package:mobile/shared/models/movie.dart';
import 'package:mobile/shared/models/post.dart';
import 'package:mobile/shared/models/post_detail_data.dart';
import 'package:mobile/shared/models/user_summary.dart';
import 'package:mobile/shared/widgets/post_card.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../shared/screens/post_detail_screen.dart';
import '../../shared/screens/user_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final location = state.matchedLocation;

      final isLoggedIn = authState.asData?.value != null;
      final isLoading = authState.isLoading;

      final isAuthRoute = location == '/login' || location == '/register';

      if (isLoading) {
        return null;
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/posts/:id',
        builder: (context, state) {
          final post = state.extra as PostDetailData;
          return PostDetailScreen(post: post);
        },
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['id']!);
          return UserDetailScreen(userId: userId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PopScope(
            canPop: false, // Intercept back gestures/buttons globally on tabs
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              // 1. If NOT on the Home tab (index 0), jump back to Home
              if (navigationShell.currentIndex != 0) {
                navigationShell.goBranch(0);
                return;
              }

              // 2. If already on Home, show exit confirmation dialog
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit App'),
                  content: const Text(
                    'Are you sure you want to exit the application?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Exit',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldExit == true) {
                SystemNavigator.pop(); // Safely close the app
              }
            },
            child: Scaffold(
              body: navigationShell,
              bottomNavigationBar: Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  navigationBarTheme: NavigationBarThemeData(
                    // Removes the Material 3 state layer overlay color on tap/hover
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                    ),
                  ),
                  child: NavigationBar(
                    indicatorColor: Color.fromARGB(0, 0, 0, 0),
                    animationDuration: Duration(milliseconds: 0),
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: navigationShell.goBranch,
                    height: 54,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(
                          Icons.home_rounded,
                          size: 32,
                          // color: Color.fromARGB(168, 255, 255, 255),
                        ),
                        selectedIcon: Icon(
                          Icons.home_rounded,
                          color: Color.fromARGB(255, 231, 44, 53),

                          size: 32,
                        ),
                        label: '',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.explore_outlined,
                          size: 32,
                          // color: Color.fromARGB(168, 255, 255, 255),
                        ),
                        selectedIcon: Icon(
                          Icons.explore_rounded,
                          size: 32,
                          color: Color.fromARGB(255, 231, 44, 53),
                        ),
                        label: '',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          size: 32,
                          // color: Color.fromARGB(168, 255, 255, 255),
                        ),
                        selectedIcon: Icon(
                          Icons.add_circle_rounded,
                          size: 32,
                          color: Color.fromARGB(255, 231, 44, 53),
                        ),
                        label: '',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.search_rounded,
                          size: 32,
                          // color: Color.fromARGB(168, 255, 255, 255),
                        ),
                        selectedIcon: Icon(
                          Icons.search_rounded,
                          size: 32,
                          color: Color.fromARGB(255, 231, 44, 53),
                        ),
                        label: '',
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.person_rounded,
                          size: 32,
                          // color: Color.fromARGB(168, 255, 255, 255),
                        ),
                        selectedIcon: Icon(
                          Icons.person,
                          size: 32,
                          color: Color.fromARGB(255, 231, 44, 53),
                        ),
                        label: '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const CreateScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  final currentUser = ref.read(authProvider).value;

                  if (currentUser == null) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return UserDetailScreen(
                    userId: currentUser.id,
                    isOwnProfile: true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
