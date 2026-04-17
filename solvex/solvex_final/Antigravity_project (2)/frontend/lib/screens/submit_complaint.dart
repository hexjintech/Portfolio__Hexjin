import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import '../providers/realtime_provider.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _title = '';
  String _description = '';
  String _location = '';
  String _place = '';
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  int? _categoryId;
  bool _isGeocoding = false;

  final List<String> _districts = [
    'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 
    'Tirunelveli', 'Erode', 'Vellore', 'Thoothukudi', 'Dindigul',
  ];
  String? _selectedDistrict;
  
  List<Category> _categories = [];
  bool _isLoading = false;
  
  Uint8List? _imageBytes;
  String? _imageName;

  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  // Sub-category mapping
  final Map<String, List<String>> _subCategoryMap = {
    'Education and learning': ['Lack of Teachers', 'Poor Facilities', 'Exam Delays', 'Unhygienic Conditions', 'Other'],
    'Electricity': ['Power Outage', 'Flickering Lights', 'Voltage Issues', 'Street Light Not Working', 'Other'],
    'Transport and infrastructure': ['Potholes', 'Broken Bridges', 'Lack of Public Transport', 'Traffic Light Failure', 'Other'],
    'Agriculture': ['Lack of Water Supply', 'Fertilizer Shortage', 'Crop Damage', 'Market Access Issue', 'Other'],
    'Rural and environment': ['Waste Management', 'Open Drainage', 'Drinking Water Shortage', 'Street Light Issue', 'Other'],
    'Water': ['Drinking Water Shortage', 'Water Leakage', 'No Water Supply', 'Contaminated Water', 'Other'],
    'Road': ['Potholes', 'Broken Road', 'Road Blockage', 'Flooded Road', 'Other'],
    'Street Light': ['Not Working', 'Flickering', 'Missing Pole', 'Hazardous Wiring', 'Other'],
    'Cleanliness / Hygiene': ['Dirty surroundings', 'Waste management', 'Toilets not clean', 'Other'],
    'Staff / Service Complaints': ['Misbehavior', 'Delay in service', 'Poor response', 'Other'],
    'Infrastructure Issues': ['Broken chairs/tables', 'Damaged buildings', 'Poor ventilation', 'Other'],
    'Security Issues': ['Theft', 'Unauthorized entry', 'Safety concerns', 'Other'],
    'Academic Issues (for students)': ['Teaching quality', 'Timetable issues', 'Exam-related problems', 'Other'],
    'Others': ['General Info', 'Other'],
  };

  String? _selectedSubCategory;
  final TextEditingController _otherSubCategoryController = TextEditingController();

  @override
  void dispose() {
    _placeController.dispose();
    _pincodeController.dispose();
    _otherSubCategoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    // Hardcoding categories to ensure they instantly match the user's requested specification 
    // even if the backend hasn't been re-deployed yet.
    if (mounted) {
      setState(() {
        _categories = [
          Category(id: 1, name: 'Education and learning'),
          Category(id: 2, name: 'Electricity'),
          Category(id: 3, name: 'Transport and infrastructure'),
          Category(id: 4, name: 'Agriculture'),
          Category(id: 5, name: 'Rural and environment'),
          Category(id: 6, name: 'Water'),
          Category(id: 7, name: 'Road'),
          Category(id: 8, name: 'Street Light'),
          Category(id: 9, name: 'Cleanliness / Hygiene'),
          Category(id: 10, name: 'Staff / Service Complaints'),
          Category(id: 11, name: 'Infrastructure Issues'),
          Category(id: 12, name: 'Security Issues'),
          Category(id: 13, name: 'Academic Issues (for students)'),
          Category(id: 14, name: 'Others'),
        ];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _isGeocoding = true);
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'SolvexApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        if (address != null) {
          String? foundDistrict;
          // Try to match geocoded keys with our district list
          final geoKeys = ['state_district', 'city', 'county', 'town', 'suburb'];
          for (var key in geoKeys) {
            final val = address[key]?.toString();
            if (val != null) {
              final match = _districts.firstWhere(
                (d) => val.toLowerCase().contains(d.toLowerCase()) || d.toLowerCase().contains(val.toLowerCase()),
                orElse: () => '',
              );
              if (match.isNotEmpty) {
                foundDistrict = match;
                break;
              }
            }
          }

          setState(() {
            if (foundDistrict != null) _selectedDistrict = foundDistrict;
            _pincodeController.text = address['postcode'] ?? '';
            _placeController.text = address['road'] ?? address['suburb'] ?? address['neighbourhood'] ?? '';
            _place = _placeController.text;
          });
        }
      }
    } catch (e) {
      // ignore geocoding errors, user can still enter manually
    }
    setState(() => _isGeocoding = false);
  }

  void _showMapPicker() {
    LatLng tempLocation = _selectedLocation ?? const LatLng(13.0827, 80.2707); // Default to Chennai
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSB) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                AppBar(
                  title: const Text('Pick Location'),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop())
                  ],
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: tempLocation,
                      initialZoom: 13.0,
                      onTap: (tapPosition, point) {
                        setStateSB(() => tempLocation = point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.solvex.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: tempLocation,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedLocation = tempLocation;
                          _location = '${tempLocation.latitude.toStringAsFixed(5)}, ${tempLocation.longitude.toStringAsFixed(5)}';
                        });
                        _reverseGeocode(tempLocation.latitude, tempLocation.longitude);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('CONFIRM LOCATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      )
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.'), backgroundColor: Colors.redAccent));
      return;
    }
    _formKey.currentState!.save();
    
    if (_location.isEmpty && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a location on the map.'), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);
    
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    // Optimistic feedback: Show the user we are working on it
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text('Submitting your complaint...'),
        ],
      ),
      backgroundColor: Colors.indigo,
      duration: Duration(seconds: 2),
    ));

    try {
      final res = await ApiService.createComplaint(
        token, 
        _title, 
        'Name: $_name\nPlace: $_place\nIssue: ${(_selectedSubCategory == 'Other' ? _otherSubCategoryController.text : _selectedSubCategory) ?? "General"}\nCoordinates: $_location\n\n$_description', 
        _categoryId!, 
        _place, 
        _selectedDistrict ?? '', 
        _pincodeController.text, 
        _imageBytes, 
        _imageName
      );
      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Complaint registered successfully!'),
              ],
            ), 
            backgroundColor: Color(0xFF76FF03)
          ));
          
          // Refresh data immediately
          Provider.of<RealtimeProvider>(context, listen: false).refreshData();
          
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to submit complaint');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/icon.png', height: 28),
            const SizedBox(width: 10),
            const Text('SOLVEX', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(!isDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: cs.surface,
        child: _categories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Card(
                    elevation: 0,
                    color: cs.surfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), 
                      side: BorderSide(color: cs.onSurface.withOpacity(0.05))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Complaint Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.primary)),
                                if (_isLoading)
                                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              style: TextStyle(color: cs.onSurface),
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                              onSaved: (val) => _name = val!,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _placeController,
                              style: TextStyle(color: cs.onSurface),
                              decoration: InputDecoration(
                                labelText: 'Place / Street',
                                prefixIcon: const Icon(Icons.place),
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (val) => val!.isEmpty ? 'Enter place' : null,
                              onSaved: (val) => _place = val!,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              style: TextStyle(color: cs.onSurface),
                              decoration: InputDecoration(
                                labelText: 'Subject / Title',
                                prefixIcon: const Icon(Icons.title),
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (val) => val!.isEmpty ? 'Enter title' : null,
                              onSaved: (val) => _title = val!,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              style: TextStyle(color: cs.onSurface),
                              decoration: InputDecoration(
                                labelText: 'Detailed Description',
                                prefixIcon: const Icon(Icons.description),
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              maxLines: 4,
                              validator: (val) => val!.isEmpty ? 'Enter description' : null,
                              onSaved: (val) => _description = val!,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              style: TextStyle(color: cs.onSurface),
                              dropdownColor: cs.surfaceVariant,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                prefixIcon: const Icon(Icons.category),
                                filled: true,
                                fillColor: cs.onSurface.withOpacity(0.06),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: TextStyle(color: cs.onSurface)))).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _categoryId = val;
                                  _selectedSubCategory = null;
                                  _otherSubCategoryController.clear();
                                });
                              },
                            ),
                            if (_categoryId != null && 
                                _subCategoryMap.containsKey(_categories.firstWhere((c) => c.id == _categoryId).name)) ...[
                              const SizedBox(height: 16),
                              FadeInDown(
                                duration: const Duration(milliseconds: 300),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSubCategory,
                                  style: TextStyle(color: cs.onSurface),
                                  dropdownColor: cs.surfaceVariant,
                                  decoration: InputDecoration(
                                    labelText: 'Specific Issue',
                                    prefixIcon: const Icon(Icons.info_outline, size: 20),
                                    filled: true,
                                    fillColor: cs.onSurface.withOpacity(0.06),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  items: _subCategoryMap[_categories.firstWhere((c) => c.id == _categoryId).name]!
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: cs.onSurface))))
                                      .toList(),
                                  onChanged: (val) => setState(() => _selectedSubCategory = val),
                                  validator: (val) => val == null ? 'Please select a specific issue' : null,
                                ),
                              ),
                            ],
                            if (_selectedSubCategory == 'Other') ...[
                              const SizedBox(height: 16),
                              FadeInDown(
                                duration: const Duration(milliseconds: 300),
                                child: TextFormField(
                                  controller: _otherSubCategoryController,
                                  style: TextStyle(color: cs.onSurface),
                                  decoration: InputDecoration(
                                    labelText: 'Please specify the issue',
                                    prefixIcon: const Icon(Icons.edit_note),
                                    filled: true,
                                    fillColor: cs.onSurface.withOpacity(0.06),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  validator: (val) => (_selectedSubCategory == 'Other' && (val == null || val.isEmpty)) ? 'Please describe the issue' : null,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Text('Location Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary)),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _showMapPicker,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                decoration: BoxDecoration(
                                  color: cs.onSurface.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.primary.withOpacity(0.3))
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.map, color: cs.primary),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _selectedLocation == null ? 'Tap to pick location on Map' : _location,
                                        style: TextStyle(color: _selectedLocation == null ? cs.onSurface.withOpacity(0.5) : cs.onSurface, fontWeight: _selectedLocation != null ? FontWeight.bold : FontWeight.normal),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.2))
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDistrict,
                                    style: TextStyle(color: cs.onSurface),
                                    dropdownColor: cs.surfaceVariant,
                                    decoration: InputDecoration(
                                      labelText: 'District',
                                      prefixIcon: const Icon(Icons.location_city),
                                      filled: true,
                                      fillColor: cs.onSurface.withOpacity(0.06),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    ),
                                    items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: TextStyle(color: cs.onSurface)))).toList(),
                                    onChanged: (val) => setState(() => _selectedDistrict = val),
                                    validator: (val) => val == null ? 'Select district' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _pincodeController,
                                    style: TextStyle(color: cs.onSurface),
                                    decoration: InputDecoration(
                                      labelText: 'Pin Code',
                                      prefixIcon: const Icon(Icons.pin_drop),
                                      suffixIcon: _isGeocoding ? const SizedBox(width: 15, height: 15, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                                      filled: true,
                                      fillColor: cs.onSurface.withOpacity(0.06),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (val) => val!.isEmpty ? 'Enter pin code' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text('Evidence (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary)),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                decoration: BoxDecoration(
                                  color: cs.onSurface.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.primary.withOpacity(0.3), style: BorderStyle.solid)
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.camera_alt, color: cs.primary),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _imageName ?? 'Tap to upload a photo',
                                        style: TextStyle(color: _imageName == null ? cs.onSurface.withOpacity(0.5) : cs.onSurface, fontWeight: _imageName != null ? FontWeight.bold : FontWeight.normal),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (_imageName != null)
                                      IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.redAccent),
                                        onPressed: () => setState(() { _imageName = null; _imageBytes = null; }),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: _submit,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Text('SUBMIT COMPLAINT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
