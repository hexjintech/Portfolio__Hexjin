import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_card.dart';
import '../models/complaint.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  final Complaint? complaint;

  const FeedbackScreen({super.key, this.complaint});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  String? _selectedCategory;
  String? _selectedIssueType;
  bool _isLoading = false;

  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  final List<String> _categories = [
    'Education and Training',
    'Electricity',
    'Transport and Infrastructure',
    'Agriculture',
    'Rural Environment',
    'Water',
    'Road',
    'Street Light'
  ];

  final Map<String, List<String>> _issueMap = {
    'Education and Training': ['Lack of Teachers', 'Poor Facilities', 'Exam Delays', 'Unhygienic Conditions'],
    'Electricity': ['Power Cut', 'Voltage Fluctuations', 'Broken Poles/Wires', 'Transformer Issue'],
    'Transport and Infrastructure': ['Potholes', 'Broken Bridges', 'Lack of Public Transport', 'Traffic Light Failure'],
    'Agriculture': ['Lack of Water Supply', 'Fertilizer Shortage', 'Crop Damage', 'Market Access Issue'],
    'Rural Environment': ['Waste Management', 'Open Drainage', 'Drinking Water Shortage', 'Street Light Issue'],
    'Water': ['Drinking Water Shortage', 'Water Leakage', 'No Water Supply', 'Contaminated Water'],
    'Road': ['Potholes', 'Broken Road', 'Road Blockage', 'Flooded Road'],
    'Street Light': ['Not Working', 'Flickering', 'Missing Pole', 'Hazardous Wiring'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.complaint != null) {
      _searchController.text = "Feedback for: ${widget.complaint!.title}";
      _locationController.text = widget.complaint!.location;
      if (widget.complaint!.pincode != null) {
        _pincodeController.text = widget.complaint!.pincode!;
      }
      if (widget.complaint!.district != null) {
         _stateController.text = widget.complaint!.district!; // using district as a pre-fill for state/region
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate() && _rating > 0) {
      setState(() => _isLoading = true);
      
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final Map<String, dynamic> data = {
        'complaint_id': widget.complaint?.id ?? '',
        'person_name': _personNameController.text,
        'subject': _searchController.text,
        'category': _selectedCategory,
        'issue_type': _selectedIssueType,
        'location': _locationController.text,
        'pincode': _pincodeController.text,
        'state': _stateController.text,
        'rating': _rating,
        'comment': _commentController.text,
      };

      try {
        final response = await ApiService.submitFeedback(token, data);
        if (response.statusCode == 201) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF0A0F14),
              title: const Text('Thank You!', style: TextStyle(color: Color(0xFF76FF03))),
              content: const Text('Your feedback has been submitted successfully.', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(ctx).pop(); // close dialog
                  Navigator.of(context).pop(); // pop screen
                }, child: const Text('OK'))
              ],
            )
          );
        } else {
          _showError('Failed to submit feedback.');
        }
      } catch (e) {
        _showError('Network error occurred.');
      }
      
      if (mounted) {
         setState(() => _isLoading = false);
      }
    } else if (_rating == 0) {
       _showError('Please provide a rating');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentIssues = _selectedCategory != null ? _issueMap[_selectedCategory!]! : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FEEDBACK', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B2FF), Color(0xFF76FF03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF00050A)),
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF76FF03)))
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(child: const Text('We value your input', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
                const SizedBox(height: 10),
                FadeInDown(delay: const Duration(milliseconds: 200), child: Text('Help us improve the Solvex experience', style: TextStyle(fontSize: 16, color: Colors.grey[400]))),
                const SizedBox(height: 32),
                
                FadeInUp(
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                         _buildTextField('Person Name', _personNameController, Icons.person_outline),
                         const SizedBox(height: 16),
                         _buildTextField('Search Subject/Topic', _searchController, Icons.search, isEnabled: widget.complaint == null),
                         const SizedBox(height: 16),
                         _buildDropdown('Category', _categories, _selectedCategory, (val) {
                           setState(() {
                             _selectedCategory = val;
                             _selectedIssueType = null; // reset issue type when category changes
                           });
                         }),
                         const SizedBox(height: 16),
                         if (_selectedCategory != null) ...[
                            _buildDropdown('Type of Issue', currentIssues, _selectedIssueType, (val) => setState(() => _selectedIssueType = val)),
                            const SizedBox(height: 16),
                         ],
                         _buildTextField('Select Location', _locationController, Icons.location_on_outlined),
                         const SizedBox(height: 16),
                         Row(
                           children: [
                             Expanded(child: _buildTextField('Pincode', _pincodeController, Icons.pin_drop_outlined, isNumeric: true)),
                             const SizedBox(width: 16),
                             Expanded(child: _buildTextField('State', _stateController, Icons.map_outlined)),
                           ],
                         ),
                         const SizedBox(height: 24),
                         const Text('Rating', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 8),
                         _buildRatingStars(),
                         const SizedBox(height: 24),
                         _buildTextField('Comment/Suggestions', _commentController, Icons.comment_outlined, isMultiline: true),
                         const SizedBox(height: 32),
                         SizedBox(
                           width: double.infinity,
                           height: 50,
                           child: ElevatedButton(
                             onPressed: _submitFeedback,
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFF00B2FF),
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                             child: const Text('SUBMIT FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                           ),
                         ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isMultiline = false, bool isNumeric = false, bool isEnabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: isEnabled,
      maxLines: isMultiline ? 4 : 1,
      keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
      style: TextStyle(color: isEnabled ? Colors.white : Colors.white54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isEnabled ? Colors.white70 : Colors.white38),
        prefixIcon: Icon(icon, color: isEnabled ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white12)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white12.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B2FF))),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Field required' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.white, backgroundColor: Color(0xFF0A0F14))))).toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF0A0F14),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null ? 'Select option' : null,
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => setState(() => _rating = index + 1),
          icon: Icon(
            index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFF76FF03),
            size: 36,
          ),
        );
      }),
    );
  }
}
