import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:converf/core/media/app_image_picker.dart';
import '../../../../../features/profile/models/profile_models.dart';
import '../../../../../features/profile/providers/profile_providers.dart';

class ProfileInformationScreen extends ConsumerStatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  ConsumerState<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends ConsumerState<ProfileInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _bioController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _countryController = TextEditingController();

  String? _lastProfileSnapshot;
  bool _hasChanges = false;
  bool _isSyncing = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _cityController,
      _stateController,
      _bioController,
      _companyNameController,
      _countryController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (_isSyncing) return;
    setState(() => _hasChanges = true);
  }

  void _syncFromProfile(UserProfile profile) {
    final snapshot = [
      profile.firstName,
      profile.lastName,
      profile.email,
      profile.phoneNumber ?? '',
      profile.city ?? '',
      profile.state ?? '',
      profile.bio ?? '',
      profile.companyName ?? '',
      profile.country ?? '',
    ].join('|');

    if (snapshot == _lastProfileSnapshot) return;

    _isSyncing = true;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phoneNumber ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _bioController.text = profile.bio ?? '';
    _companyNameController.text = profile.companyName ?? '';
    _countryController.text = profile.country ?? 'Nigeria';
    _isSyncing = false;
    _hasChanges = false;
    _lastProfileSnapshot = snapshot;
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
      _cityController,
      _stateController,
      _bioController,
      _companyNameController,
      _countryController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ref
        .read(appImagePickerProvider)
        .pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1080,
          maxHeight: 1080,
        );

    if (pickedFile != null) {
      final success = await ref
          .read(profileNotifierProvider.notifier)
          .updateProfilePicture(pickedFile.path);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _formError = null);

    final payload = UpdateProfilePayload(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      companyName: _companyNameController.text.trim().isEmpty
          ? null
          : _companyNameController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
    );

    final success = await ref.read(profileNotifierProvider.notifier).updateProfile(payload);
    if (mounted && success) {
      setState(() {
        _hasChanges = false;
        _formError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _formError = 'Failed to update profile');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final actionState = ref.watch(profileNotifierProvider);

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
      body: profileAsync.when(
        data: (profile) {
          _syncFromProfile(profile);
          final serverError = _formError ?? (actionState.hasError ? actionState.error.toString() : null);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (serverError != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        serverError,
                        style: const TextStyle(color: Color(0xFFB42318), fontSize: 13),
                      ),
                    ),
                  ],
                // Avatar with camera icon — left aligned
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: actionState.isLoading ? null : _pickAndUploadImage,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image:
                              profile.avatarUrl != null ||
                                  profile.profilePicture != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    profile.avatarUrl ??
                                        profile.profilePicture!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            profile.avatarUrl == null &&
                                profile.profilePicture == null
                            ? const Icon(
                                Icons.person,
                                size: 64,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: actionState.isLoading
                            ? null
                            : _pickAndUploadImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: actionState.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/images/camera.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
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
                      child: _buildField(
                        'First name',
                        _firstNameController,
                        enabled: !actionState.isLoading,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        'Last name',
                        _lastNameController,
                        enabled: !actionState.isLoading,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Company Name
                _buildField(
                  'Company Name',
                  _companyNameController,
                  hint: 'Enter Company Name',
                  enabled: !actionState.isLoading,
                  validator: (v) => v != null && v.length > 80 ? 'Too long' : null,
                ),
                const SizedBox(height: 16),

                // Email (readonly)
                _buildField(
                  'Email address',
                  _emailController,
                  enabled: false,
                  fillColor: const Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 16),

                // Phone Number
                _buildField(
                  'Phone Number',
                  _phoneController,
                  hint: 'Enter Phone Number',
                  enabled: !actionState.isLoading,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final digits = v.replaceAll(RegExp(r'[^0-9+]'), '');
                    if (digits.length < 7) return 'Looks too short';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Country (read-only for now)
                _buildField(
                  'Country',
                  _countryController,
                  enabled: false,
                  fillColor: const Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 16),

                // City & State
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        'City',
                        _cityController,
                        hint: 'Enter City',
                        enabled: !actionState.isLoading,
                        validator: (v) => v != null && v.length > 60 ? 'Too long' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        'State',
                        _stateController,
                        hint: 'Enter State',
                        enabled: !actionState.isLoading,
                        validator: (v) => v != null && v.length > 60 ? 'Too long' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bio
                _buildField(
                  'Bio',
                  _bioController,
                  hint: 'Tell us about yourself',
                  maxLines: 3,
                  enabled: !actionState.isLoading,
                  validator: (v) => v != null && v.length > 240 ? 'Keep it under 240 characters' : null,
                ),
                const SizedBox(height: 32),

                // Save Changes button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasChanges && !actionState.isLoading
                        ? _saveChanges
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasChanges
                          ? const Color(0xFF2A8090)
                          : const Color(0xFFD1D5DB),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: actionState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _hasChanges
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                  ),
                ),
              ],
          ),
          ),
        );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool enabled = true,
    Color? fillColor,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: fillColor ?? Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
