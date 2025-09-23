import 'package:flutter/material.dart';

/* =============================== MODELS ================================ */

class UserProfile {
  String accountType; // "candidate" | "business"
  String firstName;
  String lastName;
  String email;
  String phone;
  String location; // City, Country
  String desiredRole; // For candidates
  String workType; // Onsite/Hybrid/Remote
  int yearsOfExperience;
  List<String> skills;
  String bio; // Brief description
  String companyName; // For business
  String companyAbout; // For business

  UserProfile({
    this.accountType = 'candidate',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.desiredRole = '',
    this.workType = 'Hybrid',
    this.yearsOfExperience = 0,
    List<String>? skills,
    this.bio = '',
    this.companyName = '',
    this.companyAbout = '',
  }) : skills = skills ?? <String>[];

  Map<String, dynamic> toJson() => {
    'accountType': accountType,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'location': location,
    'desiredRole': desiredRole,
    'workType': workType,
    'yearsOfExperience': yearsOfExperience,
    'skills': skills,
    'bio': bio,
    'companyName': companyName,
    'companyAbout': companyAbout,
  };
}

/* ============================== UI SCREEN ============================== */

class UserProfileFormScreen extends StatefulWidget {
  const UserProfileFormScreen({super.key});

  @override
  State<UserProfileFormScreen> createState() => _UserProfileFormScreenState();
}

class _UserProfileFormScreenState extends State<UserProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profile = UserProfile();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _desiredRoleCtrl = TextEditingController();
  final _yoeCtrl = TextEditingController(text: '0');
  final _bioCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _companyAboutCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _locationCtrl,
      _desiredRoleCtrl,
      _yoeCtrl,
      _bioCtrl,
      _companyNameCtrl,
      _companyAboutCtrl,
      _skillCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // Helpers
  void _addSkillChip() {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty) return;
    if (!_profile.skills.contains(s)) setState(() => _profile.skills.add(s));
    _skillCtrl.clear();
  }

  void _removeSkill(String s) => setState(() => _profile.skills.remove(s));

  String? _emailValidator(String? v) {
    v = v?.trim() ?? '';
    if (v.isEmpty) return 'Required';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
    return ok ? null : 'Invalid email';
  }

  void _saveThenNavigate() {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Please fix the errors');
      return;
    }
    _formKey.currentState!.save();

    // Map form controllers into model
    _profile
      ..firstName = _firstNameCtrl.text.trim()
      ..lastName = _lastNameCtrl.text.trim()
      ..email = _emailCtrl.text.trim()
      ..phone = _phoneCtrl.text.trim()
      ..location = _locationCtrl.text.trim()
      ..desiredRole = _desiredRoleCtrl.text.trim()
      ..yearsOfExperience = int.tryParse(_yoeCtrl.text.trim()) ?? 0
      ..bio = _bioCtrl.text.trim()
      ..companyName = _companyNameCtrl.text.trim()
      ..companyAbout = _companyAboutCtrl.text.trim();

    // Navigate based on account type
    if (_profile.accountType == 'candidate') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => JobsFeedScreen(profile: _profile)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BusinessHiringScreen(profile: _profile)),
      );
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _accountTypeCard(),
              const SizedBox(height: 20),
              _basicInfoCard(),
              const SizedBox(height: 20),
              if (_profile.accountType == 'candidate') ...[
                _candidateInfoCard(),
                const SizedBox(height: 20),
                _skillsCard(),
              ] else ...[
                _businessInfoCard(),
              ],
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: _saveThenNavigate,
                icon: const Icon(Icons.arrow_forward),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Save & Continue'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /* ------------------------------- Sections ------------------------------- */

  Widget _accountTypeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'I am a...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'candidate',
                  label: Text('Job Seeker'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: 'business',
                  label: Text('Hiring Manager'),
                  icon: Icon(Icons.business),
                ),
              ],
              selected: {_profile.accountType},
              onSelectionChanged: (s) => setState(() => _profile.accountType = s.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'First Name *'),
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name *'),
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: _emailValidator,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone *'),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'City, Country (e.g., New York, USA)',
              ),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Brief Bio',
                hintText: 'Tell us about yourself in a few words...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _candidateInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Job Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desiredRoleCtrl,
              decoration: const InputDecoration(
                labelText: 'Desired Role *',
                hintText: 'e.g., Flutter Developer, Marketing Manager',
              ),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _profile.workType,
                    items: const [
                      DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
                      DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                      DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                    ],
                    onChanged: (v) => setState(() => _profile.workType = v!),
                    decoration: const InputDecoration(labelText: 'Work Type'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _yoeCtrl,
                    decoration: const InputDecoration(labelText: 'Years of Experience *'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Enter a valid number';
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Add a skill',
                      hintText: 'e.g., Flutter, Marketing, Design',
                    ),
                    onSubmitted: (_) => _addSkillChip(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _addSkillChip,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _profile.skills.isEmpty
                ? const Text(
                    'No skills added yet.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _profile.skills
                        .map((s) => InputChip(
                              label: Text(s),
                              onDeleted: () => _removeSkill(s),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _businessInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                hintText: 'e.g., Tech Solutions Inc.',
              ),
              validator: (v) => _profile.accountType == 'business' && (v?.trim().isEmpty ?? true)
                  ? 'Required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyAboutCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'About Your Company',
                hintText: 'Tell us about your company and what you do...',
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/* ============================ DESTINATION SCREENS ============================ */

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String workType; // Onsite/Hybrid/Remote
  final String description;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workType,
    required this.description,
  });
}

final _mockJobs = <Job>[
  Job(
    id: '1',
    title: 'Flutter Developer',
    company: 'TechCorp',
    location: 'New York',
    workType: 'Hybrid',
    description: 'Build and ship Flutter apps for mobile platforms.',
  ),
  Job(
    id: '2',
    title: 'Marketing Manager',
    company: 'StartupXYZ',
    location: 'Remote',
    workType: 'Remote',
    description: 'Lead marketing campaigns and grow our user base.',
  ),
  Job(
    id: '3',
    title: 'Sales Representative',
    company: 'SalesPro',
    location: 'Chicago',
    workType: 'Onsite',
    description: 'Drive sales growth and build client relationships.',
  ),
  Job(
    id: '4',
    title: 'Graphic Designer',
    company: 'CreativeStudio',
    location: 'Los Angeles',
    workType: 'Hybrid',
    description: 'Create visual designs for digital and print media.',
  ),
];

class JobsFeedScreen extends StatefulWidget {
  final UserProfile profile;
  const JobsFeedScreen({super.key, required this.profile});

  @override
  State<JobsFeedScreen> createState() => _JobsFeedScreenState();
}

class _JobsFeedScreenState extends State<JobsFeedScreen> {
  String _query = '';
  String _workType = 'Any';

  List<Job> _filtered() {
    return _mockJobs.where((j) {
      final qOk = _query.isEmpty ||
          j.title.toLowerCase().contains(_query.toLowerCase()) ||
          j.company.toLowerCase().contains(_query.toLowerCase());
      final wtOk = _workType == 'Any' || j.workType == _workType;

      return qOk && wtOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filtered();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _JobsFilters(
            initialQuery: widget.profile.desiredRole,
            onQuery: (v) => setState(() => _query = v),
            onWorkType: (v) => setState(() => _workType = v),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final j = jobs[i];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        j.company.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(j.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${j.company} • ${j.location} • ${j.workType}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showJob(j),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: jobs.length,
            ),
          ),
        ],
      ),
    );
  }

  void _showJob(Job j) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: controller,
              children: [
                Text(
                  j.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${j.company} • ${j.location} • ${j.workType}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Job Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(j.description),
                const SizedBox(height: 30),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied to ${j.title} at ${j.company}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Apply Now'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JobsFilters extends StatefulWidget {
  final void Function(String) onQuery;
  final void Function(String) onWorkType;
  final String initialQuery;
  const _JobsFilters({
    required this.onQuery,
    required this.onWorkType,
    this.initialQuery = '',
  });

  @override
  State<_JobsFilters> createState() => _JobsFiltersState();
}

class _JobsFiltersState extends State<_JobsFilters> {
  late final TextEditingController _searchCtrl;
  String _workType = 'Any';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search jobs or companies',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onQuery,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _workType,
              items: const [
                DropdownMenuItem(value: 'Any', child: Text('Any Work Type')),
                DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
              ],
              onChanged: (v) {
                setState(() => _workType = v!);
                widget.onWorkType(v!);
              },
              decoration: const InputDecoration(
                labelText: 'Work Type',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessHiringScreen extends StatefulWidget {
  final UserProfile profile;
  const BusinessHiringScreen({super.key, required this.profile});

  @override
  State<BusinessHiringScreen> createState() => _BusinessHiringScreenState();
}

class _BusinessHiringScreenState extends State<BusinessHiringScreen> {
  final _formKey = GlobalKey<FormState>();

  final _jobTitleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();

  String _workType = 'Onsite';
  final List<String> _requiredSkills = [];

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    _descriptionCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillsCtrl.text.trim();
    if (s.isEmpty) return;
    if (!_requiredSkills.contains(s)) setState(() => _requiredSkills.add(s));
    _skillsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Job • ${p.companyName.isEmpty ? "Your Business" : p.companyName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Job Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jobTitleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Job Title *',
                          hintText: 'e.g., Flutter Developer, Marketing Manager',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _workType,
                        items: const [
                          DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
                          DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                          DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                        ],
                        onChanged: (v) => setState(() => _workType = v!),
                        decoration: const InputDecoration(labelText: 'Work Type'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Job Description *',
                          hintText: 'Describe the role and responsibilities...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Required Skills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _skillsCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Add a skill',
                                hintText: 'e.g., Flutter, Marketing, Design',
                              ),
                              onSubmitted: (_) => _addSkill(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _addSkill,
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _requiredSkills.isEmpty
                          ? const Text(
                              'No skills added yet.',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _requiredSkills
                                  .map((s) => InputChip(
                                        label: Text(s),
                                        onDeleted: () => setState(() => _requiredSkills.remove(s)),
                                      ))
                                  .toList(),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: _submitJob,
                icon: const Icon(Icons.publish),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Post Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitJob() {
    if (!_formKey.currentState!.validate()) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job "${_jobTitleCtrl.text}" posted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear form
    _jobTitleCtrl.clear();
    _descriptionCtrl.clear();
    _skillsCtrl.clear();
    setState(() {
      _requiredSkills.clear();
    });
  }
}