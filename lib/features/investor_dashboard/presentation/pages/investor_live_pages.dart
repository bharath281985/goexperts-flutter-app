import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_location_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_avatar_editor.dart';
import '../../../../core/utils/result.dart';

class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  State<InvestorProfilePage> createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  final _email = TextEditingController();
  final _fullName = TextEditingController();
  final _company = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController();
  final _city = TextEditingController();
  final _bio = TextEditingController();

  String? _avatarUrl;
  String? _localAvatarPath;
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
    _phone.dispose();
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
          user['fullName']?.toString() ??
          user['full_name']?.toString() ??
          m['fullName']?.toString() ??
          m['full_name']?.toString() ??
          m['name']?.toString() ??
          '';
      _company.text = m['company']?.toString() ?? m['firm']?.toString() ?? '';
      _phone.text = user['phone']?.toString() ?? m['phone']?.toString() ?? '';
      _country.text =
          user['country']?.toString() ?? m['country']?.toString() ?? '';

      final city = user['city']?.toString();
      final location = m['location']?.toString();
      _city.text = city ?? location ?? '';

      _bio.text = m['bio']?.toString() ?? user['bio']?.toString() ?? '';
      _avatarUrl =
          user['avatarUrl']?.toString() ??
          user['avatar_url']?.toString() ??
          m['avatarUrl']?.toString() ??
          m['avatar_url']?.toString();
      _verified =
          m['isVerified'] as bool? ??
          m['verified'] as bool? ??
          user['verified'] as bool? ??
          false;
    });
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final fullName = _fullName.text.trim();

    if (fullName.isEmpty) {
      context.showSnack('Name is required', isError: true);
      return;
    }

    setState(() => _saving = true);
    final Map<String, dynamic> body = {
      'name': fullName,
      'fullName': fullName,
      'company': _company.text.trim(),
      'firm': _company.text.trim(),
      'phone': _phone.text.trim(),
      'country': _country.text.trim(),
      'city': _city.text.trim(),
      'location': _city.text.trim(),
      'bio': _bio.text.trim(),
      if (_avatarUrl != null) 'avatarUrl': _avatarUrl,
    };

    final Result<Map<String, dynamic>> res;
    if (_localAvatarPath != null) {
      res = await sl<FileUploadHelper>().upload(
        path: _localAvatarPath!,
        endpoint: ApiEndpoints.investorProfile,
        fileField: 'file',
        method: 'put',
        fields: body,
      );
    } else {
      res = await sl<ApiClientHelper>().put<Map<String, dynamic>>(
        ApiEndpoints.investorProfile,
        body: body,
        parser: (raw) => Map<String, dynamic>.from(raw as Map),
      );
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      if (res.isSuccess) {
        _localAvatarPath = null;
      }
    });

    res.fold((f) => context.showSnack(f.message, isError: true), (json) {
      context.showSnack('Investor profile updated');
      final url =
          json['avatarUrl']?.toString() ??
          json['url']?.toString() ??
          _avatarUrl;
      if (url != null) {
        setState(() {
          _avatarUrl = url;
        });
      }
      final currentUser = context.read<AuthBloc>().state.user;
      if (currentUser != null) {
        context.read<AuthBloc>().add(
          AuthUserUpdated(
            currentUser.copyWith(
              fullName: fullName,
              location: _city.text.trim(),
              avatarUrl: _avatarUrl,
              phone: _phone.text.trim(),
            ),
          ),
        );
      }
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Investor Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      Text(
                        _verified
                            ? 'Verified investor'
                            : 'Verification pending',
                      ),
                      const Spacer(),
                      Text('Completion ${_completion()}%'),
                    ],
                  ),
                ),
                AppSizes.vGapXl,
                ProfileAvatarEditor(
                  localPath: _localAvatarPath,
                  networkUrl: _avatarUrl,
                  onPathPicked: (path) =>
                      setState(() => _localAvatarPath = path),
                ),
                AppSizes.vGapXl,
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'Email Address',
                  readOnly: true,
                ),
                AppSizes.vGapMd,
                AppTextField(
                  controller: _fullName,
                  label: 'Name',
                  hint: 'Enter your name',
                ),
                AppSizes.vGapMd,
                AppTextField(
                  controller: _company,
                  label: 'Company',
                  hint: 'Enter company name',
                ),
                AppSizes.vGapMd,
                AppTextField(
                  controller: _phone,
                  label: 'Phone',
                  hint: 'Enter your phone number',
                ),
                AppSizes.vGapMd,
                AppTextField(
                  controller: _country,
                  label: 'Country',
                  hint: 'Enter your country',
                ),
                AppSizes.vGapMd,
                AppLocationField(
                  controller: _city,
                  label: 'City',
                  hint: 'Search and select your city',
                ),
                AppSizes.vGapMd,
                AppTextField(
                  controller: _bio,
                  label: 'Bio',
                  hint: 'Enter your bio',
                  maxLines: 3,
                ),

                AppPrimaryButton(
                  label: 'Save',
                  isLoading: _saving,
                  onPressed: _save,
                ),
                AppSizes.vGapXl,
              ],
            ),
    );
  }

  int _completion() {
    final values = [_fullName.text, _company.text, _city.text, _bio.text];
    final filled = values.where((e) => e.trim().isNotEmpty).length;
    return ((filled / 4) * 100).round();
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
