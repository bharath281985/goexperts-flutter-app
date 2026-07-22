import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/utils/phone_validation.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_location_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/country_code_field.dart';

class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  State<InvestorProfilePage> createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _fullName = TextEditingController();
  final _company = TextEditingController();
  final _phoneCode = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _country = TextEditingController();
  final _city = TextEditingController();
  final _bio = TextEditingController();

  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String _countryCode = '+91';
  String _countryIsoCode = 'IN';
  String _countryName = 'India';
  bool _loading = true;
  bool _saving = false;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _fullName.dispose();
    _company.dispose();
    _phoneCode.dispose();
    _phoneNumber.dispose();
    _country.dispose();
    _city.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>().get<Map<String, dynamic>>(
      ApiEndpoints.investorProfile,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    res.fold((f) => context.showSnack(f.message), (m) {
      final user = m['user'] as Map<String, dynamic>? ?? {};
      _email.text = user['email']?.toString() ?? m['email']?.toString() ?? '';
      _fullName.text =
          user['fullName']?.toString() ?? m['name']?.toString() ?? '';
      _company.text = m['company']?.toString() ?? m['firm']?.toString() ?? '';
      _countryCode =
          user['phoneCode']?.toString() ??
          user['countryCode']?.toString() ??
          m['phoneCode']?.toString() ??
          m['countryCode']?.toString() ??
          '+91';
      _phoneCode.text = _countryCode;
      _countryIsoCode = _countryIsoFromDialCode(_countryCode);
      _countryName = _countryNameFromIso(_countryIsoCode);
      _phoneNumber.text = PhoneValidation.trimToRequiredLength(
        user['phoneNumber']?.toString() ??
            user['mobileNo']?.toString() ??
            user['phone']?.toString() ??
            m['phoneNumber']?.toString() ??
            m['mobileNo']?.toString() ??
            m['phone']?.toString() ??
            '',
        _countryIsoCode,
      );
      _country.text =
          user['country']?.toString() ?? m['country']?.toString() ?? '';

      final city =
          user['address']?.toString() ??
          user['city']?.toString() ??
          m['address']?.toString();
      final location = m['location']?.toString();
      _city.text = city ?? location ?? '';

      _bio.text = m['bio']?.toString() ?? user['bio']?.toString() ?? '';
      _avatarUrl = user['avatarUrl']?.toString() ?? m['avatarUrl']?.toString();
      _verified =
          m['isVerified'] as bool? ??
          m['verified'] as bool? ??
          user['verified'] as bool? ??
          false;
    });
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fullName = _fullName.text.trim();

    setState(() => _saving = true);
    final res = await sl<ApiClientHelper>().put<Map<String, dynamic>>(
      ApiEndpoints.investorProfile,
      body: {
        'name': fullName,
        'fullName': fullName,
        'company': _company.text.trim(),
        'firm': _company.text.trim(),
        'phoneCode': _countryCode,
        'countryCode': _countryCode,
        'phoneNumber': _phoneNumber.text.trim(),
        'mobileNo': _phoneNumber.text.trim(),
        'phone': _phoneNumber.text.trim(),
        'country': _country.text.trim(),
        'city': _city.text.trim(),
        'address': _city.text.trim(),
        'location': _city.text.trim(),
        'bio': _bio.text.trim(),
        if (_avatarUrl != null) 'avatarUrl': _avatarUrl,
      },
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold(
      (f) => context.showSnack(f.message, isError: true),
      (_) => context.showSnack(context.tr('Investor profile updated')),
    );
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
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': 'avatar'},
    );
    if (!mounted) return;
    setState(() => _saving = false);

    res.fold((f) => context.showSnack(f.message, isError: true), (url) {
      setState(() => _avatarUrl = url.isEmpty ? _avatarUrl : url);
    });
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

  Future<void> _uploadDoc() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: false);
    final path = picked?.files.single.path;
    if (path == null) return;
    final direct = await sl<FileUploadHelper>().uploadUrl(
      path: path,
      endpoint: ApiEndpoints.investorProfileDocuments,
    );
    if (!mounted) return;
    if (direct.isSuccess) {
      context.showSnack(context.tr('Document uploaded'));
      return;
    }
    final fallback = await sl<FileUploadHelper>().uploadUrl(
      path: path,
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': 'investor_document'},
    );
    if (!mounted) return;
    fallback.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack(context.tr('Document uploaded via files API')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(context.tr('Investor Profile'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        Text(
                          context.tr(
                            _verified
                                ? 'Verified investor'
                                : 'Verification pending',
                          ),
                        ),
                        const Spacer(),
                        Text('${context.tr('Completion')} ${_completion()}%'),
                      ],
                    ),
                  ),
                  AppSizes.vGapXl,
                  Center(
                    child: Stack(
                      children: [
                        AppAvatar(
                          name: _fullName.text.trim().isEmpty
                              ? context.tr('Investor')
                              : _fullName.text.trim(),
                          imageUrl: _avatarUrl,
                          imageBytes: _avatarBytes,
                          size: 100,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: _saving ? null : _pickAvatar,
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
                  AppSizes.vGapMd,
                  AppTextField(
                    controller: _company,
                    label: 'Company',
                    hint: 'Enter company name',
                    validator: (v) =>
                        _requiredValidator(v, 'Company name is required'),
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
                  AppTextField(
                    controller: _country,
                    label: 'Country',
                    hint: 'Enter your country',
                    validator: (v) =>
                        _requiredValidator(v, 'Country is required'),
                  ),
                  AppSizes.vGapMd,
                  AppLocationField(
                    controller: _city,
                    label: 'Address',
                    hint: 'Search and select your address',
                    validator: (v) =>
                        _requiredValidator(v, 'Address is required'),
                  ),
                  AppSizes.vGapMd,
                  AppTextField(
                    controller: _bio,
                    label: 'Bio',
                    hint: 'Enter your bio',
                    maxLines: 3,
                    validator: (v) => _requiredValidator(v, 'Bio is required'),
                  ),
                  AppSizes.vGapLg,
                  AppPrimaryButton(
                    label: 'Upload Document',
                    onPressed: _uploadDoc,
                  ),
                  AppSizes.vGapMd,
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

  int _completion() {
    final values = [_fullName.text, _company.text, _city.text, _bio.text];
    final filled = values.where((e) => e.trim().isNotEmpty).length;
    return ((filled / 4) * 100).round();
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

class InvestorDocumentsLivePage extends StatefulWidget {
  const InvestorDocumentsLivePage({super.key});

  @override
  State<InvestorDocumentsLivePage> createState() =>
      _InvestorDocumentsLivePageState();
}

class _InvestorDocumentsLivePageState extends State<InvestorDocumentsLivePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _docs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>()
        .getEnvelope<List<Map<String, dynamic>>>(
          ApiEndpoints.investorDocuments,
          parser: (e) {
            final list = e.data as List?;
            if (list == null) return const [];
            return list
                .whereType<Map>()
                .map((x) => Map<String, dynamic>.from(x))
                .toList();
          },
        );
    if (!mounted) return;
    _docs = res.valueOrNull ?? const [];
    setState(() => _loading = false);
  }

  Future<void> _upload() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: false);
    final path = picked?.files.single.path;
    if (path == null) return;
    final direct = await sl<FileUploadHelper>().uploadUrl(
      path: path,
      endpoint: ApiEndpoints.investorDocumentsUpload,
    );
    if (!mounted) return;
    if (direct.isSuccess) {
      context.showSnack('Uploaded');
      await _load();
      return;
    }
    final fallback = await sl<FileUploadHelper>().uploadUrl(
      path: path,
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': 'investor_document'},
    );
    if (!mounted) return;
    fallback.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Uploaded via files API'),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [TextButton(onPressed: _upload, child: const Text('Upload'))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  if (_docs.isEmpty)
                    const AppCard(child: Text('No documents yet')),
                  for (final d in _docs)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Text(
                        d['name']?.toString() ??
                            d['title']?.toString() ??
                            'Document',
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class InvestorReportsLivePage extends StatefulWidget {
  const InvestorReportsLivePage({super.key});

  @override
  State<InvestorReportsLivePage> createState() =>
      _InvestorReportsLivePageState();
}

class _InvestorReportsLivePageState extends State<InvestorReportsLivePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _reports = const [];
  Map<String, dynamic> _portfolio = const {};
  Map<String, dynamic> _roi = const {};
  Map<String, dynamic> _analytics = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = sl<ApiClientHelper>();
    final r = await api.getEnvelope<List<Map<String, dynamic>>>(
      ApiEndpoints.investorReports,
      parser: (e) {
        final list = e.data as List?;
        if (list == null) return const [];
        return list
            .whereType<Map>()
            .map((x) => Map<String, dynamic>.from(x))
            .toList();
      },
    );
    final p = await api.get<Map<String, dynamic>>(
      ApiEndpoints.investorReportsPortfolio,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final roi = await api.get<Map<String, dynamic>>(
      ApiEndpoints.investorReportsRoi,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final analytics = await api.get<Map<String, dynamic>>(
      ApiEndpoints.investorAnalytics,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    _reports = r.valueOrNull ?? const [];
    _portfolio = p.valueOrNull ?? const {};
    _roi = roi.valueOrNull ?? const {};
    _analytics = analytics.valueOrNull ?? const {};
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Investor Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  AppCard(
                    child: Text(
                      'Portfolio report: ${_portfolio['summary'] ?? '—'}',
                    ),
                  ),
                  AppSizes.vGapSm,
                  AppCard(child: Text('ROI report: ${_roi['summary'] ?? '—'}')),
                  AppSizes.vGapSm,
                  AppCard(
                    child: Text(
                      'Analytics summary: ${_analytics['summary'] ?? _analytics['portfolioValue'] ?? '—'}',
                    ),
                  ),
                  AppSizes.vGapSm,
                  for (final rep in _reports)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Text(rep['title']?.toString() ?? 'Report'),
                    ),
                ],
              ),
            ),
    );
  }
}

class InvestorAnalyticsLivePage extends StatefulWidget {
  const InvestorAnalyticsLivePage({super.key});

  @override
  State<InvestorAnalyticsLivePage> createState() =>
      _InvestorAnalyticsLivePageState();
}

class _InvestorAnalyticsLivePageState extends State<InvestorAnalyticsLivePage> {
  bool _loading = true;
  Map<String, dynamic> _data = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>().get<Map<String, dynamic>>(
      ApiEndpoints.investorAnalytics,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    _data = res.valueOrNull ?? const {};
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Investor Analytics')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                children: [
                  _metric('Portfolio Value', _data['portfolioValue']),
                  _metric('Investments', _data['investments']),
                  _metric('Watchlist', _data['watchlist']),
                  _metric('Meetings', _data['meetings']),
                  _metric('Recommendations', _data['recommendations']),
                  _metric('Notifications', _data['notifications']),
                ],
              ),
            ),
    );
  }

  Widget _metric(String label, dynamic value) => AppCard(
    child: Row(
      children: [Text(label), const Spacer(), Text(value?.toString() ?? '—')],
    ),
  );
}
