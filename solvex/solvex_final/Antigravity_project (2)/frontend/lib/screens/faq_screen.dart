import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> _faqs = [
    {'q': 'How do I report a new complaint?', 'a': 'Tap the "New Complaint" button on your dashboard, fill in the details, and attach a photo of the issue.'},
    {'q': 'How long does it take to resolve an issue?', 'a': 'Resolution times vary by department, but you can track the real-time progress on your dashboard.'},
    {'q': 'Can I edit my complaint after submission?', 'a': 'Currently, complaints cannot be edited once submitted. You may add further details in the feedback section.'},
    {'q': 'What happens if my complaint is rejected?', 'a': 'An authority remark will be provided with the rejection reason. You can resubmit or appeal if necessary.'},
    {'q': 'Is my personal information safe?', 'a': 'Yes, your data is encrypted and only used for the purpose of resolving your report.'},
  ];

  List<Map<String, String>> _filteredFaqs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _faqs;
  }

  void _filterFaqs(String query) {
    setState(() {
      _filteredFaqs = _faqs.where((f) => f['q']!.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FREQUENTLY ASKED QUESTIONS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFaqs,
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredFaqs.length,
              itemBuilder: (ctx, i) => FadeInUp(
                delay: Duration(milliseconds: i * 50),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(_filteredFaqs[i]['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(_filteredFaqs[i]['a']!, style: TextStyle(color: cs.onSurface.withOpacity(0.6), height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
