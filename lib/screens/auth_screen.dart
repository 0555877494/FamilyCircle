import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/family_service.dart';
import '../models/family_user.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final user = await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (user != null) {
          _navigateToHome();
        } else {
          setState(() => _errorMessage = 'Invalid email or password');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    final fakeUser = FamilyUser(
      id: 'demo_user',
      familyId: 'demo_family',
      firstName: 'Demo',
      role: UserRole.parent,
      createdAt: DateTime.now(),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: fakeUser)),
    );
  }

  void _demoMode() {
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
return PopScope(
       canPop: false,
       child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.family_restroom, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Family Circle',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect with your family',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: const Text('Create Family'),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinFamilyScreen()),
                    );
                  },
                  child: const Text('Join Existing Family'),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _demoMode,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Demo Mode'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _familyNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final familyService = context.read<FamilyService>();
      
      final user = await authService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        final family = await familyService.createFamily(
          _familyNameController.text,
          user.uid,
        );
        
        if (family != null) {
          await familyService.addMember(
            family.id, 
            _firstNameController.text, 
            UserRole.parent,
          );
          
          await authService.saveUserSession(user.uid, family.id);
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToHome() {
    final fakeUser = FamilyUser(
      id: 'demo_user',
      familyId: 'demo_family',
      firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : 'Demo',
      role: UserRole.parent,
      createdAt: DateTime.now(),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: fakeUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Family')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _familyNameController,
                decoration: const InputDecoration(
                  labelText: 'Family Name',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Family'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _codeController = TextEditingController();
  final _firstNameController = TextEditingController();
  bool _isLoading = false;
  bool _isParent = true;

  Future<void> _join() async {
    setState(() => _isLoading = true);
    
    try {
      final familyService = context.read<FamilyService>();
      final success = await familyService.joinFamilyWithCode(
        _codeController.text,
        'demo_user',
        _firstNameController.text,
        _isParent ? UserRole.parent : UserRole.child,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          _navigateToHome();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid invite code')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    final fakeUser = FamilyUser(
      id: 'demo_user',
      familyId: 'demo_family',
      firstName: _firstNameController.text.isNotEmpty ? _firstNameController.text : 'Demo',
      role: _isParent ? UserRole.parent : UserRole.child,
      createdAt: DateTime.now(),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: fakeUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Family')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Invite Code',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('I am a parent'),
                value: _isParent,
                onChanged: (v) => setState(() => _isParent = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _join,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Join Family'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}