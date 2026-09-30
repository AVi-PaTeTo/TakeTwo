import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Required for SystemNavigator.pop()
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/create/screens/create_screen.dart';
import 'package:mobile/features/explore/screens/explore_screen.dart';
import 'package:mobile/features/search/screens/search_screen.dart';
import 'package:mobile/shared/models/post_detail_data.dart';

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
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: navigationShell.goBranch,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline),
                    selectedIcon: Icon(Icons.add_circle),
                    label: 'Create',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
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
