import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/application_model.dart';
import '../../models/opportunity_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/startup_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme.dart';

class ApplicantsScreen extends StatelessWidget {
  final OpportunityModel opportunity;

  const ApplicantsScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final startupProvider = context.watch<StartupProvider>();
    final applicants = startupProvider.applicantsFor(opportunity.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Applicants'),
            Text(opportunity.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: applicants.isEmpty
          ? const Center(
              child: Text('No applicants yet',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applicants.length,
              itemBuilder: (context, i) =>
                  _ApplicantCard(application: applicants[i]),
            ),
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  final ApplicationModel application;

  const _ApplicantCard({required this.application});

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  UserModel? _student;
  bool _loading = true;

  static const _statuses = [
    'applied',
    'under_review',
    'shortlisted',
    'accepted',
    'closed',
  ];

  static const _statusLabels = {
    'applied': 'Applied',
    'under_review': 'Under Review',
    'shortlisted': 'Shortlisted',
    'accepted': 'Accepted',
    'closed': 'Closed',
  };

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final user = await FirestoreService().getUser(widget.application.studentUid);
    if (mounted) {
      setState(() {
        _student = user;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _student?.name ?? 'Unknown Applicant',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Applied ${DateFormat('MMM d, yyyy').format(widget.application.appliedAt)}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (widget.application.cvUrl.isNotEmpty)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('View CV'),
                    onPressed: () => launchUrl(Uri.parse(widget.application.cvUrl)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
              ],
            ),
            if (widget.application.coverLetter.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Applicant Pitch:',
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.application.coverLetter,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.onBackground),
              ),
            ],
            const SizedBox(height: 16),
            Text('Update status:',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _statuses
                  .map((s) => ChoiceChip(
                        label: Text(_statusLabels[s]!,
                            style: GoogleFonts.poppins(fontSize: 12)),
                        selected: widget.application.status == s,
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        onSelected: (_) {
                          context
                              .read<StartupProvider>()
                              .updateApplicationStatus(widget.application.id, s);
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
