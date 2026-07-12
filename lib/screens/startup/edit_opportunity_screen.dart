import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/startup_provider.dart';
import '../../models/opportunity_model.dart';
import '../../theme.dart';

class EditOpportunityScreen extends StatefulWidget {
  final OpportunityModel opportunity;
  
  const EditOpportunityScreen({super.key, required this.opportunity});

  @override
  State<EditOpportunityScreen> createState() => _EditOpportunityScreenState();
}

class _EditOpportunityScreenState extends State<EditOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _commitmentCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  String _category = 'Engineering';
  List<String> _skills = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.opportunity.title;
    _commitmentCtrl.text = widget.opportunity.commitment;
    _locationCtrl.text = widget.opportunity.location;
    _descCtrl.text = widget.opportunity.description;
    _category = widget.opportunity.category;
    _skills = List.from(widget.opportunity.skills);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _commitmentCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() => _skills.add(s));
      _skillCtrl.clear();
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one required skill')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<StartupProvider>().updateOpportunity(
            id: widget.opportunity.id,
            title: _titleCtrl.text.trim(),
            category: _category,
            skills: _skills,
            commitment: _commitmentCtrl.text.trim(),
            location: _locationCtrl.text.trim(),
            description: _descCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opportunity updated!'),
          backgroundColor: AppColors.verified,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Opportunity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Role title'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: kCategories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commitmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Commitment',
                  hintText: 'e.g. Part-time 8–10 hrs/wk',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter commitment level' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. On-campus Kigali / Remote',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.length < 20 ? 'Write at least 20 characters' : null,
              ),
              const SizedBox(height: 20),
              Text('Required skills',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _skills
                    .map((s) => Chip(
                          label: Text(s),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _skills.remove(s)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Add skill...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.add),
                    onPressed: _addSkill,
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _update, child: const Text('Update Opportunity')),
            ],
          ),
        ),
      ),
    );
  }
}
