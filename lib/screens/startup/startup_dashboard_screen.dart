import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../models/opportunity_model.dart';
import '../../theme.dart';
import 'post_opportunity_screen.dart';
import 'edit_opportunity_screen.dart';
import 'applicants_screen.dart';

class StartupDashboardScreen extends StatelessWidget {
  const StartupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final startupProvider = context.watch<StartupProvider>();
    final startup = startupProvider.startup;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Startup Dashboard'),
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
      body: startup == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Startup header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.business,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(startup.name,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            _StatusBadge(status: startup.status),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Pending banner
                  if (startup.isPending) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.pending.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.pending.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top,
                              color: AppColors.pending, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your startup is pending verification. You can draft opportunities but they won\'t be visible to students until approved.',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.onBackground),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (startup.isRejected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verification rejected',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                                if (startup.rejectionReason != null)
                                  Text(
                                    startup.rejectionReason!,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.onBackground),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Opportunities',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (startup.isVerified || startup.isPending)
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PostOpportunityScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Post'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (startupProvider.opportunities.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No opportunities posted yet.',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...startupProvider.opportunities
                        .map((opp) => _OpportunityManageCard(opp: opp)),
                ],
              ),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'verified':
        return AppColors.verified;
      case 'rejected':
        return AppColors.rejected;
      default:
        return AppColors.pending;
    }
  }

  String get _label {
    switch (status) {
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending Verification';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        _label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _OpportunityManageCard extends StatelessWidget {
  final OpportunityModel opp;

  const _OpportunityManageCard({required this.opp});

  Color get _statusColor {
    switch (opp.status) {
      case 'open':
        return AppColors.verified;
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupProvider = context.read<StartupProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ApplicantsScreen(opportunity: opp),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Expanded(
                  child: Text(opp.title,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opp.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(opp.category,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicantsScreen(opportunity: opp),
                    ),
                  ),
                  icon: const Icon(Icons.people_outlined, size: 16),
                  label: const Text('Applicants'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      startupProvider.toggleOpportunityStatus(opp),
                  icon: Icon(
                    opp.status == 'open'
                        ? Icons.pause_outlined
                        : Icons.play_arrow_outlined,
                    size: 16,
                  ),
                  label:
                      Text(opp.status == 'open' ? 'Close' : 'Open'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditOpportunityScreen(opportunity: opp),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete opportunity?'),
                        content:
                            const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete',
                                  style:
                                      TextStyle(color: AppColors.error))),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      startupProvider.deleteOpportunity(opp.id);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
