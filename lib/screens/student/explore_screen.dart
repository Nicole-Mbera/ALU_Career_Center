import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/opportunity_model.dart';
import '../../theme.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _showSavedOnly = false;

  @override
  Widget build(BuildContext context) {
    final opps = context.watch<OpportunityProvider>();
    final auth = context.watch<AuthProvider>();
    final bookmarkedIds = auth.user?.bookmarkedOppIds ?? [];
    
    final displayedOpps = _showSavedOnly
        ? opps.filtered.where((o) => bookmarkedIds.contains(o.id)).toList()
        : opps.filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: opps.setSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by role or skill...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: opps.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => opps.setSearch(''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filters', style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        Text('Saved only', style: GoogleFonts.poppins(fontSize: 13)),
                        Switch(
                          value: _showSavedOnly,
                          onChanged: (v) => setState(() => _showSavedOnly = v),
                          activeColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Category filters
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: kCategories
                        .map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: opps.categoryFilter == cat,
                                selectedColor:
                                    AppColors.primary.withOpacity(0.15),
                                onSelected: (_) => opps.setCategory(cat),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: opps.categoryFilter == cat
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: opps.categoryFilter == cat
                                      ? AppColors.primary
                                      : AppColors.onSurface,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Campus filter
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Kigali', 'Mauritius']
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: opps.campusFilter == c,
                                selectedColor:
                                    AppColors.secondary.withOpacity(0.2),
                                onSelected: (_) => opps.setCampus(c),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: opps.campusFilter == c
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: opps.campusFilter == c
                                      ? AppColors.pending
                                      : AppColors.onSurface,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${displayedOpps.length} result${displayedOpps.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: displayedOpps.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text('No opportunities found',
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: displayedOpps.length,
                    itemBuilder: (context, i) {
                      final opp = displayedOpps[i];
                      return OpportunityCard(
                        opportunity: opp,
                        matchScore: opps.matchScore(opp.skills),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OpportunityDetailScreen(opportunity: opp),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
