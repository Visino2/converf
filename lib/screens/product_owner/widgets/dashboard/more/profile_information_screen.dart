import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final _firstNameController = TextEditingController(text: 'Gabriella');
  final _lastNameController = TextEditingController(text: 'McPherson');
  final _emailController =
      TextEditingController(text: 'thegabriellamcpherson@email.com');
  final _companyController = TextEditingController();
  final _roleController = TextEditingController(text: 'Account Manager');

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _companyController,
      _roleController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with camera icon — left aligned
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/gabriella.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset('assets/images/camera.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // First Name & Last Name
            Row(
              children: [
                Expanded(
                  child: _buildField('First name', _firstNameController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('Last name', _lastNameController),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email (readonly/disabled look)
            _buildField(
              'Email address',
              _emailController,
              enabled: false,
              fillColor: const Color(0xFFF3F4F6),
            ),
            const SizedBox(height: 16),

            // Company Name
            _buildField('Company Name', _companyController,
                hint: 'Enter Company Name'),
            const SizedBox(height: 16),

            // Role
            _buildField('Role', _roleController),
            const SizedBox(height: 32),

            // Save Changes button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasChanges ? () => Navigator.pop(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasChanges ? const Color(0xFF2A8090) : const Color(0xFFD1D5DB),
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _hasChanges ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool enabled = true,
    Color? fillColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: fillColor ?? Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A8090)),
            ),
          ),
        ),
      ],
    );
  }
}
