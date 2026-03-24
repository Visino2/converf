import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../features/profile/models/profile_models.dart';
import '../../../../../features/profile/providers/profile_providers.dart';

class ProfileInformationScreen extends ConsumerStatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  ConsumerState<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends ConsumerState<ProfileInformationScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _bioController = TextEditingController();

  bool _hasChanges = false;
  bool _initialized = false;

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
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (_initialized) {
      setState(() => _hasChanges = true);
    }
  }

  void _initializeControllers(UserProfile profile) {
    if (!_initialized) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phoneNumber ?? '';
      _cityController.text = profile.city ?? '';
      _stateController.text = profile.state ?? '';
      _bioController.text = profile.bio ?? '';
      _initialized = true;
    }
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
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      try {
        await ref.read(profileNotifierProvider.notifier).updateProfilePicture(pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile picture: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    final payload = UpdateProfilePayload(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
    );

    try {
      await ref.read(profileNotifierProvider.notifier).updateProfile(payload);
      setState(() => _hasChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
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
          _initializeControllers(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          image: profile.avatarUrl != null || profile.profilePicture != null
                              ? DecorationImage(
                                  image: NetworkImage(profile.avatarUrl ?? profile.profilePicture!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profile.avatarUrl == null && profile.profilePicture == null
                            ? const Icon(Icons.person, size: 64, color: Colors.grey)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: actionState.isLoading ? null : _pickAndUploadImage,
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
                                : SvgPicture.asset('assets/images/camera.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                      child: _buildField('First name', _firstNameController, enabled: !actionState.isLoading),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField('Last name', _lastNameController, enabled: !actionState.isLoading),
                    ),
                  ],
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
                _buildField('Phone Number', _phoneController, hint: 'Enter Phone Number', enabled: !actionState.isLoading),
                const SizedBox(height: 16),

                // City & State
                Row(
                  children: [
                    Expanded(
                      child: _buildField('City', _cityController, hint: 'Enter City', enabled: !actionState.isLoading),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField('State', _stateController, hint: 'Enter State', enabled: !actionState.isLoading),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bio
                _buildField('Bio', _bioController, hint: 'Tell us about yourself', maxLines: 3, enabled: !actionState.isLoading),
                const SizedBox(height: 32),

                // Save Changes button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasChanges && !actionState.isLoading ? _saveChanges : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasChanges ? const Color(0xFF2A8090) : const Color(0xFFD1D5DB),
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
                              color: _hasChanges ? Colors.white : Colors.white70,
                            ),
                          ),
                  ),
                ),
              ],
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
          maxLines: maxLines,
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
