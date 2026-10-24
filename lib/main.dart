
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/bookmark.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simple_icons/simple_icons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LinkVaultApp());
}

class LinkVaultApp extends StatelessWidget {
  const LinkVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1120),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B1120),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF818CF8),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _links = [];

  String _selectedCategory = 'All';
  
  final List<String> _availableCategories = [
  'Development',
  'Learning',
  'Design',
  'Tools',
  'Other',
];

  static const _background = Color(0xFF0B1120);
  static const _surface = Color(0xFF172033);
  static const _accent = Color(0xFF818CF8);


  
  List<Map<String, dynamic>> get _filteredLinks {
    final query = _searchController.text.toLowerCase();

    return _links.where((link) {
      final rawCategories = link['categories'];

      final List<String> categories = rawCategories is List
          ? rawCategories.map((item) => item.toString()).toList()
          : link['category'] is String
              ? [link['category'] as String]
              : [];

      final matchesCategory = _selectedCategory == 'All' ||
          categories.contains(_selectedCategory);

      final matchesSearch =
          (link['title'] ?? '').toString().toLowerCase().contains(query) ||
          (link['url'] ?? '').toString().toLowerCase().contains(query) ||
          categories.any(
            (category) => category.toLowerCase().contains(query),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Future<Map<String, dynamic>?> _fetchGitHubRepo(
  String url,
) async {
  final uri = Uri.tryParse(url.trim());

  if (uri == null || uri.host.toLowerCase() != 'github.com') {
    return null;
  }

  final parts = uri.pathSegments;

  if (parts.length < 2) {
    return null;
  }

  final owner = parts[0];
  final repo = parts[1].replaceFirst(RegExp(r'\.git$'), '');

  if (owner.isEmpty || repo.isEmpty) {
    return null;
  }

  final apiUrl = Uri.https(
    'api.github.com',
    '/repos/$owner/$repo',
  );

  final response = await http.get(
    apiUrl,
    headers: {
      'Accept': 'application/vnd.github+json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(
      'GitHub could not find this repository '
      '(HTTP ${response.statusCode}).',
    );
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  return {
    'title': data['full_name'] ?? '$owner/$repo',
    'url': data['html_url'] ?? url,
    'description': data['description'] ?? 'No description provided.',
    'language': data['language'] ?? 'Not specified',
    'stars': data['stargazers_count'] ?? 0,
    'forks': data['forks_count'] ?? 0,
    'ownerAvatar': data['owner']?['avatar_url'] ?? '',
    'type': 'github',
  };
}

  
Future<void> _addLink() async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => AddLinkDialog(
      availableCategories: _availableCategories,
      onCategoryCreated: () {
        if (mounted) {
          setState(() {});
        }
      },
    ),  
  );

  if (!mounted || result == null) return;

  setState(() {
    _links.insert(0, result);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Link added to your library')),
  );
}


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final filteredLinks = _filteredLinks;
    final categories = ['All', ..._availableCategories];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.bookmarks_rounded, color: _accent),
            SizedBox(width: 10),
            Text(
              'LinkVault',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  user!.email!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLink,
        backgroundColor: _accent,
        foregroundColor: _background,
        icon: const Icon(Icons.add_link),
        label: const Text('Add Link'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'YOUR DIGITAL LIBRARY',
                  style: TextStyle(
                    color: _accent,
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Save what matters.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your useful websites, all in one place.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 28),

                // Search
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search your saved websites...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    fillColor: _surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 600 ? 3 : 1;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 4.0 : 2.4,
                      children: [
                        _statCard(
                          Icons.bookmark,
                          '${_links.length}',
                          'Saved links',
                        ),
                        _statCard(
                          Icons.folder_outlined,
                          '${_links.map((e) => e['category']).toSet().length}',
                          'Categories used',
                        ),
                        _statCard(
                          Icons.filter_alt_outlined,
                          '${filteredLinks.length}',
                          'Matching results',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Category filters
                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: _accent,
                      backgroundColor: _surface,
                      labelStyle: TextStyle(
                        color: _selectedCategory == category
                            ? _background
                            : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Saved links
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your collection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredLinks.length} links',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (filteredLinks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.library_books_outlined,
                          size: 52,
                          color: _accent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _links.isEmpty
                              ? 'Your library starts here'
                              : 'No matching websites',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _links.isEmpty
                              ? 'Click Add Link to save your first website.'
                              : 'Try another search or category.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        if (_links.isEmpty) ...[
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _addLink,
                            icon: const Icon(Icons.add),
                            label: const Text('Save your first link'),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ...filteredLinks.map((link) {
                    return Card(
                      color: _surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF273449),
                          child: (Uri.tryParse(link['url'] ?? '')?.host.toLowerCase() ==
                                      'github.com')
                              ? const Icon(
                                  SimpleIcons.github,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Icon(
                                  _platformIcon(link['url'] ?? ''),
                                  color: const Color(0xFF818CF8),
                                ),
                        ),
                        title: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (link['categories'] as List? ?? [])
                                .map(
                                  (category) => Chip(
                                    label: Text(category.toString()),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: const Color(0xFF273449),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF818CF8),
                                    ),
                                    side: BorderSide.none,
                                  ),
                                )
                                .toList(),
                          ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link['url'] ?? '',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              if ((link['note'] ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  link['note']!,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove link',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() => _links.remove(link));
                          },
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Website opening will be added next.',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
  IconData _platformIcon(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';

    if (host == 'github.com' || host.endsWith('.github.com')) {
      return Icons.code;
    }

    if (host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'youtu.be') {
      return Icons.play_circle_fill;
    }

    if (host == 'medium.com' || host.endsWith('.medium.com')) {
      return Icons.article;
    }

    if (host == 'stackoverflow.com') {
      return Icons.question_answer;
    }

    if (host == 'linkedin.com' || host.endsWith('.linkedin.com')) {
      return Icons.work;
    }

    return Icons.language;
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome back, ${credential.user?.email}!',
        ),
      ),
    );
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String message;

    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        message = 'Incorrect email or password.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Check your internet connection.';
        break;
      default:
        message = 'Sign in failed. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.bookmarks_rounded,
                    size: 64,
                    color: Color(0xFF818CF8),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'LinkVault',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your internet toolbox, organized.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to access your saved websites.',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 28),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(                      
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Create one",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() =>
      _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account created for ${credential.user?.email}',
        ),
      ),
    );

    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String message;

    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already registered.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'weak-password':
        message = 'Choose a stronger password.';
        break;
      case 'operation-not-allowed':
        message = 'Enable Email/Password in Firebase Console.';
        break;
      case 'network-request-failed':
        message = 'Check your internet connection.';
        break;
      default:
        message = 'Registration failed. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.bookmarks_rounded,
                    size: 56,
                    color: Color(0xFF818CF8),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Join LinkVault',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Create your account and organize your web.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full name
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email address
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }

                      if (value.length < 6) {
                        return 'Use at least 6 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child:FilledButton(
                      onPressed: _isLoading ? null : _handleCreateAccount,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text("Already have an account?"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddLinkDialog extends StatefulWidget {
  final List<String> availableCategories;
  final VoidCallback onCategoryCreated;

  const AddLinkDialog({
    super.key,
    required this.availableCategories,
    required this.onCategoryCreated,
  });

  @override
  State<AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<AddLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  final Set<String> _selectedCategories = {'Other'};

  @override
void dispose() {
  _urlController.dispose();
  _titleController.dispose();
  _noteController.dispose();
  super.dispose();
}
Future<void> _createCategory() async {
  final controller = TextEditingController();

  final category = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Create category'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Category name',
          hintText: 'e.g. Machine Learning',
        ),
        onSubmitted: (_) {
          final name = controller.text.trim();
          if (name.isNotEmpty) {
            Navigator.pop(dialogContext, name);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(dialogContext, name);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );

  controller.dispose();

  if (category == null || !mounted) return;

  final normalizedCategory = category.trim();

  if (normalizedCategory.isEmpty) return;

  final existingCategory = widget.availableCategories.where(
    (item) => item.toLowerCase() == normalizedCategory.toLowerCase(),
  );

  setState(() {
    if (existingCategory.isEmpty) {
      widget.availableCategories.add(normalizedCategory);
    }

    final savedCategory = existingCategory.isEmpty
        ? normalizedCategory
        : existingCategory.first;

    _selectedCategories.add(savedCategory);
  });

  widget.onCategoryCreated();
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF172033),
      title: const Text(
        'Save a website or GitHub repository',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Website or GitHub URL',
                  hintText: 'https://github.com/flutter/flutter',
                ),
                validator: (value) {
                  final uri = Uri.tryParse(value?.trim() ?? '');

                  if (uri == null ||
                      !uri.hasScheme ||
                      !['http', 'https'].contains(uri.scheme) ||
                      uri.host.isEmpty) {
                    return 'Enter a valid HTTP or HTTPS URL';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Flutter',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter a title'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Personal note (optional)',
                  hintText: 'Why did you save this link?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.availableCategories.map((category) {
                  final selected = _selectedCategories.contains(category);

                  return FilterChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              TextButton.icon(
                onPressed: _createCategory,
                icon: const Icon(Icons.add),
                label: const Text('Create new category'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'url': _urlController.text.trim(),
              'title': _titleController.text.trim(),
              'categories': _selectedCategories.toList(),
              'note': _noteController.text.trim(),
            });
          },
          child: const Text('Save Link'),
        ),
      ],
    );
  }
}
