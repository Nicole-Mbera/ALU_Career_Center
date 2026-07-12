import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../theme.dart';
import '../../widgets/match_score_badge.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final OpportunityModel opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _applying = false;
  Uint8List? _cvBytes;
  String? _cvName;

  Future<void> _pickCV() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _cvBytes = result.files.first.bytes;
        _cvName = result.files.first.name;
      });
    }
  }

  Future<void> _apply() async {
    if (_cvBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your CV before applying')),
      );
      return;
    }
    setState(() => _applying = true);
    final auth = context.read<AuthProvider>();
    final appProvider = context.read<ApplicationProvider>();

    final success = await appProvider.apply(
      studentUid: auth.user!.uid,
      opportunityId: widget.opportunity.id,
      startupId: widget.opportunity.startupId,
      opportunityTitle: widget.opportunity.title,
      startupName: widget.opportunity.startupName,
      cvBytes: _cvBytes!,
      cvName: _cvName!,
    );

    if (!mounted) return;
    setState(() => _applying = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Application submitted successfully!'
            : 'You have already applied to this opportunity.'),
        backgroundColor: success ? AppColors.verified : AppColors.pending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opps = context.watch<OpportunityProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final opp = widget.opportunity;
    final score = opps.matchScore(opp.skills);
    final matched = opps.matchedSkills(opp.skills);
    final missing = opps.missingSkills(opp.skills);
    final hasApplied = appProvider.hasAppliedLocally(opp.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(opp.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp.startupName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        opp.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                MatchScoreBadge(score: score),
              ],
            ),
            const SizedBox(height: 16),

            // Meta row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _MetaChip(
                    icon: Icons.schedule_outlined, label: opp.commitment),
                _MetaChip(
                    icon: Icons.location_on_outlined, label: opp.location),
                _MetaChip(icon: Icons.category_outlined, label: opp.category),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            Text('About the opportunity',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(opp.description,
                style: GoogleFonts.poppins(
                    fontSize: 14, height: 1.6, color: AppColors.onBackground)),

            const SizedBox(height: 24),
            Text('Skills required',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            // Skill match breakdown
            if (matched.isNotEmpty) ...[
              Text('You have (${matched.length})',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.matchHigh,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: matched
                    .map((s) => Chip(
                          label: Text(s,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.matchHigh)),
                          backgroundColor:
                              AppColors.matchHigh.withOpacity(0.1),
                          side: BorderSide(
                              color: AppColors.matchHigh.withOpacity(0.3)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            if (missing.isNotEmpty) ...[
              Text('You\'re missing (${missing.length})',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.matchLow,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: missing
                    .map((s) => Chip(
                          label: Text(s,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.matchLow)),
                          backgroundColor:
                              AppColors.matchLow.withOpacity(0.1),
                          side: BorderSide(
                              color: AppColors.matchLow.withOpacity(0.3)),
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 32),
            Text('Your Application', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: hasApplied ? null : _pickCV,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasApplied
                        ? AppColors.divider
                        : (_cvBytes != null ? AppColors.verified : AppColors.divider),
                    width: _cvBytes != null && !hasApplied ? 2 : 1,
                  ),
                ),
                child: _cvBytes != null || hasApplied
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 36, color: hasApplied ? AppColors.textSecondary : AppColors.verified),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              hasApplied ? 'Application Submitted' : (_cvName ?? 'CV loaded'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: hasApplied ? AppColors.textSecondary : AppColors.onBackground),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file_outlined,
                              size: 32, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text('Tap to upload your CV',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _applying
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: hasApplied ? null : _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasApplied ? AppColors.divider : AppColors.primary,
                    foregroundColor:
                        hasApplied ? AppColors.textSecondary : AppColors.onPrimary,
                  ),
                  child: Text(hasApplied ? 'Applied' : 'Apply Now'),
                ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}
