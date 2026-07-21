import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/utils/phone_validation.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_location_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/category_skills_picker.dart';
import '../../../../core/widgets/country_code_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../master_data/domain/entities/skill_option.dart';

class ClientEditProfilePage extends StatelessWidget {
  const ClientEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _RoleEditProfilePage(role: _EditableProfileRole.client);
}

class FreelancerEditProfilePage extends StatelessWidget {
  const FreelancerEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) =>
      const _RoleEditProfilePage(role: _EditableProfileRole.freelancer);
}

enum _EditableProfileRole { client, freelancer }

class _RoleEditProfilePage extends StatefulWidget {
  const _RoleEditProfilePage({required this.role});

  final _EditableProfileRole role;

  @override
  State<_RoleEditProfilePage> createState() => _RoleEditProfilePageState();
}

class _RoleEditProfilePageState extends State<_RoleEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _city = TextEditingController();
  final _experience = TextEditingController();
  final _hourlyRate = TextEditingController();
  final _phoneCode = TextEditingController();
  final _phoneNumber = TextEditingController();

  final Set<String> _selectedSkillIds = {};
  final Map<String, String> _skillNamesById = {};

  String? _industryId;
  String _industryName = '';
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String _countryCode = '+91';
  String _countryIsoCode = 'IN';
  String _countryName = 'India';
  String? _categoryError;
  bool _loading = true;
  bool _saving = false;

  bool get _isClient => widget.role == _EditableProfileRole.client;
  String get _endpoint =>
      _isClient ? ApiEndpoints.clientProfile : ApiEndpoints.freelancerProfile;
  String get _avatarEndpoint => _isClient
      ? ApiEndpoints.clientProfileLogo
      : ApiEndpoints.freelancerProfileAvatar;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _company.dispose();
    _city.dispose();
    _experience.dispose();
    _hourlyRate.dispose();
    _phoneCode.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>().get<Map<String, dynamic>>(
      _endpoint,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    res.fold((f) => context.showSnack(f.message, isError: true), _applyProfile);
    setState(() => _loading = false);
  }

  void _applyProfile(Map<String, dynamic> data) {
    final user = Map<String, dynamic>.from(data['user'] as Map? ?? const {});
    _email.text = user['email']?.toString() ?? data['email']?.toString() ?? '';
    _fullName.text =
        user['fullName']?.toString() ??
        data['fullName']?.toString() ??
        data['name']?.toString() ??
        '';
    _company.text = data['company']?.toString() ?? '';
    _city.text =
        user['address']?.toString() ??
        user['city']?.toString() ??
        data['address']?.toString() ??
        data['city']?.toString() ??
        data['location']?.toString() ??
        '';
    _countryCode =
        user['phoneCode']?.toString() ??
        user['countryCode']?.toString() ??
        data['phoneCode']?.toString() ??
        data['countryCode']?.toString() ??
        '+91';
    _phoneCode.text = _countryCode;
    _countryIsoCode = _countryIsoFromDialCode(_countryCode);
    _countryName = _countryNameFromIso(_countryIsoCode);
    _phoneNumber.text = PhoneValidation.trimToRequiredLength(
      user['phoneNumber']?.toString() ??
          user['mobileNo']?.toString() ??
          data['phoneNumber']?.toString() ??
          '',
      _countryIsoCode,
    );
    _experience.text = data['experience']?.toString() ?? '';
    final rate = data['hourlyRate'] ?? data['hourly_rate'];
    _hourlyRate.text = rate == null ? '' : rate.toString();
    _industryId = data['industry']?.toString();
    _industryName = data['industryName']?.toString() ?? '';
    _avatarUrl =
        user['avatarUrl']?.toString() ??
        data['avatarUrl']?.toString() ??
        data['logoUrl']?.toString();
    _selectedSkillIds
      ..clear()
      ..addAll(_skillIds(data['skills']));
  }

  List<String> _skillIds(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((item) {
          if (item is Map) {
            final id =
                item['skillId']?.toString() ??
                item['id']?.toString() ??
                item['skill_id']?.toString();
            final name =
                item['skillName']?.toString() ??
                item['name']?.toString() ??
                item['skill_name']?.toString();
            if (id != null && name != null) _skillNamesById[id] = name;
            return id;
          }
          return item.toString();
        })
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toList();
  }

  void _onSkillOptionsLoaded(List<SkillOption> skills) {
    for (final skill in skills) {
      _skillNamesById[skill.id] = skill.name;
    }
  }

  void _setCountryCode(CountryCode countryCode) {
    setState(() {
      _countryCode = countryCode.dialCode ?? '+91';
      _phoneCode.text = _countryCode;
      _countryIsoCode = countryCode.code ?? 'IN';
      _countryName = countryCode.name ?? _countryNameFromIso(_countryIsoCode);
      _phoneNumber.text = PhoneValidation.trimToRequiredLength(
        _phoneNumber.text,
        _countryIsoCode,
      );
    });
    _formKey.currentState?.validate();
  }

  String? _requiredValidator(String? value, String message) =>
      value == null || value.trim().isEmpty ? context.tr(message) : null;

  String? _validateMobile(String? value) {
    final message = PhoneValidation.validateMobile(
      value: value,
      countryIsoCode: _countryIsoCode,
      countryName: _countryName,
    );
    return message == null ? null : context.tr(message);
  }

  String? _validateRate(String? value) {
    final required = _requiredValidator(value, 'Hourly rate is required');
    if (required != null) return required;
    final rate = double.tryParse(value!.trim());
    if (rate == null || rate <= 0) return context.tr('Enter valid hourly rate');
    return null;
  }

  bool _validateSelections() {
    final categoryError = _industryId == null || _industryId!.trim().isEmpty
        ? context.tr('Category is required')
        : null;
    setState(() {
      _categoryError = categoryError;
    });
    return categoryError == null;
  }

  Future<void> _pickAvatar() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path == null) return;
    final bytes = picked?.files.single.bytes ?? await File(path).readAsBytes();

    setState(() {
      _avatarBytes = bytes;
      _saving = true;
    });
    final res = await sl<FileUploadHelper>().uploadUrl(
      path: path,
      endpoint: _avatarEndpoint,
      fields: {'category': _isClient ? 'client-logo' : 'avatar'},
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold((f) => context.showSnack(f.message, isError: true), (url) {
      setState(() => _avatarUrl = url.isEmpty ? _avatarUrl : url);
    });
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final selectionsValid = _validateSelections();
    if (!formValid || !selectionsValid) return;

    final hourlyRate = double.tryParse(_hourlyRate.text.trim());
    final body = <String, dynamic>{
      'fullName': _fullName.text.trim(),
      'city': _city.text.trim(),
      'address': _city.text.trim(),
      'location': _city.text.trim(),
      'phoneCode': _countryCode,
      'countryCode': _countryCode,
      'phoneNumber': _phoneNumber.text.trim(),
      'mobileNo': _phoneNumber.text.trim(),
      'industry': _industryId,
      'skills': _selectedSkillIds.toList(),
      'hourlyRate': hourlyRate ?? 0,
      'experience': _experience.text.trim(),
      if (_avatarUrl != null) 'avatarUrl': _avatarUrl,
      if (_isClient) 'company': _company.text.trim(),
      if (!_isClient) 'skillIds': _selectedSkillIds.toList(),
    };

    setState(() => _saving = true);
    final res = await sl<ApiClientHelper>().putEnvelope<String>(
      _endpoint,
      body: body,
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!.trim()
          : 'Profile updated successfully',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold((f) => context.showSnack(f.message, isError: true), (message) {
      final currentUser = context.read<AuthBloc>().state.user;
      if (currentUser != null) {
        context.read<AuthBloc>().add(
          AuthUserUpdated(
            currentUser.copyWith(
              fullName: _fullName.text.trim(),
              location: _city.text.trim(),
              avatarUrl: _avatarUrl,
            ),
          ),
        );
      }
      context.showSnack(message);
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isClient ? 'Client Profile' : 'Freelancer Profile';
    return AppScaffold(
      appBar: AppBar(title: Text(context.tr(title))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        AppAvatar(
                          name: _fullName.text.trim().isEmpty
                              ? title
                              : _fullName.text.trim(),
                          imageUrl: _avatarUrl,
                          imageBytes: _avatarBytes,
                          size: 100,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            tooltip: context.tr('Change profile photo'),
                            onPressed: _saving ? null : _pickAvatar,
                            icon: const Icon(Icons.edit, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.vGapXl,
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'Email Address',
                    readOnly: true,
                    validator: (v) =>
                        _requiredValidator(v, 'Email is required'),
                  ),
                  AppSizes.vGapMd,
                  AppTextField(
                    controller: _fullName,
                    label: 'Name',
                    hint: 'Enter your name',
                    validator: (v) => _requiredValidator(v, 'Name is required'),
                  ),
                  if (_isClient) ...[
                    AppSizes.vGapMd,
                    AppTextField(
                      controller: _company,
                      label: 'Company Name',
                      hint: 'Enter company name',
                      validator: (v) =>
                          _requiredValidator(v, 'Company name is required'),
                    ),
                  ],
                  AppSizes.vGapMd,
                  CategorySkillsPicker(
                    selectedCategoryId: _industryId,
                    selectedSkillIds: _selectedSkillIds,
                    categoryLabel: 'Industry',
                    categorySubtitle: _industryName.isEmpty
                        ? 'Choose your industry'
                        : _industryName,
                    skillsSubtitle: 'Select skills that apply to you',
                    clearSkillsOnCategoryChange: true,
                    categoryError: _categoryError,
                    onCategoryChanged: (id, name) {
                      setState(() {
                        _industryId = id;
                        _industryName = name;
                        _categoryError = null;
                      });
                    },
                    onSkillsChanged: (ids) => setState(() {
                      _selectedSkillIds
                        ..clear()
                        ..addAll(ids);
                    }),
                    onSkillOptionsLoaded: _onSkillOptionsLoaded,
                  ),
                  AppSizes.vGapMd,
                  AppTextField(
                    controller: _experience,
                    label: 'Experience',
                    hint: 'Enter your experience in years',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) =>
                        _requiredValidator(v, 'Experience is required'),
                  ),
                  AppSizes.vGapMd,
                  AppTextField(
                    controller: _hourlyRate,
                    label: 'Hourly Rate',
                    hint: 'Enter your hourly rate',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _validateRate,
                  ),
                  AppSizes.vGapMd,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CountryCodeField(
                          initialSelection: _countryIsoCode,
                          onInit: (countryCode) {
                            _countryCode = countryCode.dialCode ?? _countryCode;
                            _phoneCode.text = _countryCode;
                            _countryIsoCode =
                                countryCode.code ?? _countryIsoCode;
                            _countryName = countryCode.name ?? _countryName;
                          },
                          onChanged: _setCountryCode,
                        ),
                      ),
                      AppSizes.hGapSm,
                      Expanded(
                        flex: 5,
                        child: AppTextField(
                          controller: _phoneNumber,
                          label: 'Mobile',
                          hint: 'Enter your mobile number',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              PhoneValidation.requiredLength(_countryIsoCode),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                          validator: _validateMobile,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.vGapXs,
                  Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        PhoneValidation.counterText(
                          value: _phoneNumber.text,
                          countryIsoCode: _countryIsoCode,
                        ),
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  ),
                  AppSizes.vGapMd,
                  AppLocationField(
                    controller: _city,
                    label: 'Address',
                    hint: 'Search and select your address',
                    validator: (v) =>
                        _requiredValidator(v, 'Address is required'),
                  ),
                  AppSizes.vGapXl,
                  AppPrimaryButton(
                    label: 'Save',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  AppSizes.vGapXl,
                ],
              ),
            ),
    );
  }
}

String _countryIsoFromDialCode(String dialCode) {
  switch (dialCode.trim()) {
    case '+1':
      return 'US';
    case '+44':
      return 'GB';
    case '+61':
      return 'AU';
    case '+971':
      return 'AE';
    case '+91':
    default:
      return 'IN';
  }
}

String _countryNameFromIso(String isoCode) {
  switch (isoCode.toUpperCase()) {
    case 'US':
      return 'United States';
    case 'GB':
      return 'United Kingdom';
    case 'AU':
      return 'Australia';
    case 'AE':
      return 'United Arab Emirates';
    case 'IN':
    default:
      return 'India';
  }
}
