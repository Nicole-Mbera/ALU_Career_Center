import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _skillCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _db = FirestoreService();
  bool _isEditingBio = false;

  @override
  void dispose() {
    _skillCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSkill(String skill) async {
    final auth = context.read<AuthProvider>();
    if (skill.isEmpty || auth.user == null) return;
    final skills = List<String>.from(auth.user!.skills);
    if (skills.contains(skill)) return;
    skills.add(skill);
    await _db.updateUserSkills(auth.user!.uid, skills);
    auth.refreshUser();
    context.read<OpportunityProvider>().updateStudentSkills(skills);
    _skillCtrl.clear();
  }

  Future<void> _removeSkill(String skill) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    final skills = List<String>.from(auth.user!.skills)..remove(skill);
    await _db.updateUserSkills(auth.user!.uid, skills);
    auth.refreshUser();
    context.read<OpportunityProvider>().updateStudentSkills(skills);
  }

  Future<void> _saveBio() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    await auth.updateProfile(bio: _bioCtrl.text.trim());
    setState(() => _isEditingBio = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final user = auth.user;

    final stats = [
      ('Applications', appProvider.all.length),
      ('Shortlisted', appProvider.byStatus('shortlisted').length),
      ('Accepted', appProvider.byStatus('accepted').length),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(user?.campus ?? ''),
                    avatar: const Icon(Icons.location_on, size: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bio', style: Theme.of(context).textTheme.titleMedium),
                if (!_isEditingBio)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      _bioCtrl.text = user?.bio ?? '';
                      setState(() => _isEditingBio = true);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditingBio) ...[
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tell us a bit about yourself...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: _saveBio,
                  child: const Text('Save Bio'),
                ),
              ),
            ] else if (user?.bio.isNotEmpty == true) ...[
              Text(
                user!.bio,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.onBackground),
              ),
            ] else ...[
              Text(
                'No bio added yet.',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic),
              ),
            ],

            const SizedBox(height: 24),

            // Stats row
            Row(
              children: stats
                  .map((s) => Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Text(
                                  '${s.$2}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  s.$1,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            Text('Skills & Interests',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'These are used to compute your match score for opportunities.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (user?.skills ?? [])
                  .map((s) => Chip(
                        label: Text(s),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => _removeSkill(s),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a skill (e.g. Flutter, Design)',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: _addSkill,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addSkill(_skillCtrl.text.trim()),
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
