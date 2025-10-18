import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JobsFiltersScreen extends StatefulWidget {
  final void Function(String) onQuery;
  final void Function(String) onWorkType;
  final String initialQuery;
  const JobsFiltersScreen({
    required this.onQuery,
    required this.onWorkType,
    this.initialQuery = '',
  });

  @override
  State<JobsFiltersScreen> createState() => _JobsFiltersState();
}

class _JobsFiltersState extends State<JobsFiltersScreen> {
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
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: widget.onQuery,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search jobs or companies',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF667EEA), size: 24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                const BorderSide(color: Color(0xFF667EEA), width: 2.5),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          const SizedBox(height: 18),
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Work Type',
              labelStyle: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.filter_list_rounded,
                  color: Color(0xFF667EEA), size: 24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                const BorderSide(color: Color(0xFF667EEA), width: 2.5),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}