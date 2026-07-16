import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../auth/presentation/bloc/auth_bloc.dart';

class FounderPitchDeckLivePage extends StatefulWidget {
  const FounderPitchDeckLivePage({super.key});

  @override
  State<FounderPitchDeckLivePage> createState() =>
      _FounderPitchDeckLivePageState();
}

class FounderProfileLivePage extends StatefulWidget {
  const FounderProfileLivePage({super.key});

  @override
  State<FounderProfileLivePage> createState() => _FounderProfileLivePageState();
}

class _FounderProfileLivePageState extends State<FounderProfileLivePage> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _bio = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _bio.dispose();
    super.dispose();
  }

  String _pick(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final value = m[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    final user = m['user'];
    if (user is Map) {
      for (final key in keys) {
        final value = user[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      // Nested user uses fullName / city instead of name / location.
      if (keys.contains('name')) {
        final fullName = user['fullName'];
        if (fullName != null && fullName.toString().trim().isNotEmpty) {
          return fullName.toString();
        }
      }
      if (keys.contains('location')) {
        final city = user['city'];
        if (city != null && city.toString().trim().isNotEmpty) {
          return city.toString();
        }
      }
    }
    return '';
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>().get<Map<String, dynamic>>(
      ApiEndpoints.founderProfile,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    res.fold((f) => context.showSnack(f.message, isError: true), (m) {
      _name.text = _pick(m, const ['name', 'fullName']);
      _location.text = _pick(m, const ['location', 'city']);
      _bio.text = _pick(m, const ['bio']);
    });
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final location = _location.text.trim();
    final bio = _bio.text.trim();

    if (name.isEmpty) {
      context.showSnack('Name is required', isError: true);
      return;
    }

    setState(() => _saving = true);
    final res = await sl<ApiClientHelper>().putEnvelope<String>(
      ApiEndpoints.founderProfile,
      body: {'name': name, 'fullName': name, 'location': location, 'bio': bio},
      parser: (envelope) => envelope.message?.trim().isNotEmpty == true
          ? envelope.message!
          : 'Founder profile updated successfully',
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (res.isFailure) {
      context.showSnack(res.failureOrNull!.message, isError: true);
      return;
    }

    final message = res.valueOrNull ?? 'Founder profile updated successfully';
    final currentUser = context.read<AuthBloc>().state.user;
    if (currentUser != null) {
      context.read<AuthBloc>().add(
        AuthUserUpdated(
          currentUser.copyWith(fullName: name, location: location),
        ),
      );
    }

    // Show toast after the frame so it isn't lost during rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.showSnack(message);
    });
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Founder Profile')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              AppTextField(
                controller: _name,
                label: 'Name',
                hint: 'Enter your name',
              ),
              AppSizes.vGapMd,
              AppLocationField(
                controller: _location,
                label: 'Location',
                hint: 'Search and select your location',
              ),
              AppSizes.vGapMd,
              AppTextField(
                controller: _bio,
                label: 'Bio',
                hint: 'Enter your bio',
                maxLines: 4,
              ),
              AppSizes.vGapMd,
              AppPrimaryButton(
                label: 'Save',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
  );
}

class FounderFundingLivePage extends StatefulWidget {
  const FounderFundingLivePage({super.key});
  @override
  State<FounderFundingLivePage> createState() => _FounderFundingLivePageState();
}

class _FounderFundingLivePageState extends State<FounderFundingLivePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _rounds = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>()
        .getEnvelope<List<Map<String, dynamic>>>(
          ApiEndpoints.founderFunding,
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
    _rounds = res.valueOrNull ?? const [];
    setState(() => _loading = false);
  }

  Future<void> _createRound() async {
    final res = await sl<ApiClientHelper>().post<Map<String, dynamic>>(
      ApiEndpoints.founderFunding,
      body: {'title': 'New Round', 'targetAmount': 0},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
      allowNullData: false,
    );
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Funding round created'),
    );
    await _load();
  }

  Future<void> _updateStatus(String id, String status) async {
    final res = await sl<ApiClientHelper>().patchAction(
      ApiEndpoints.founderFundingStatus(id),
      body: {'status': status},
    );
    if (!mounted) return;
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Status updated'),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(
      title: const Text('Funding'),
      actions: [TextButton(onPressed: _createRound, child: const Text('New'))],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                if (_rounds.isEmpty)
                  const AppCard(child: Text('No funding rounds yet')),
                for (final r in _rounds)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ListTile(
                      title: Text(r['title']?.toString() ?? 'Funding round'),
                      subtitle: Text('Status: ${r['status'] ?? 'draft'}'),
                      trailing: IconButton(
                        onPressed: () =>
                            _updateStatus(r['id']?.toString() ?? '', 'active'),
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
                    ),
                  ),
              ],
            ),
          ),
  );
}

class _FounderPitchDeckLivePageState extends State<FounderPitchDeckLivePage> {
  final _summary = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>().get<Map<String, dynamic>>(
      ApiEndpoints.founderPitchDeck,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    _summary.text = res.valueOrNull?['summary']?.toString() ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final api = sl<ApiClientHelper>();
    var res = await api.put<Map<String, dynamic>>(
      ApiEndpoints.founderPitchDeck,
      body: {'summary': _summary.text.trim()},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (res.isFailure) {
      res = await api.post<Map<String, dynamic>>(
        ApiEndpoints.founderPitchDeck,
        body: {'summary': _summary.text.trim()},
        parser: (raw) => Map<String, dynamic>.from(raw as Map),
        allowNullData: false,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Pitch deck saved'),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Pitch Deck')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              AppTextField(
                controller: _summary,
                label: 'Deck Summary',
                hint: 'Enter deck summary',
                maxLines: 8,
              ),
              AppSizes.vGapMd,
              AppPrimaryButton(
                label: 'Save',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
  );
}

class FounderBusinessPlanLivePage extends StatefulWidget {
  const FounderBusinessPlanLivePage({super.key});
  @override
  State<FounderBusinessPlanLivePage> createState() =>
      _FounderBusinessPlanLivePageState();
}

class _FounderBusinessPlanLivePageState
    extends State<FounderBusinessPlanLivePage> {
  final _summary = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>().get<Map<String, dynamic>>(
      ApiEndpoints.founderBusinessPlan,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (!mounted) return;
    _summary.text = res.valueOrNull?['summary']?.toString() ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final api = sl<ApiClientHelper>();
    var res = await api.put<Map<String, dynamic>>(
      ApiEndpoints.founderBusinessPlan,
      body: {'summary': _summary.text.trim()},
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    if (res.isFailure) {
      res = await api.post<Map<String, dynamic>>(
        ApiEndpoints.founderBusinessPlan,
        body: {'summary': _summary.text.trim()},
        parser: (raw) => Map<String, dynamic>.from(raw as Map),
        allowNullData: false,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Business plan saved'),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Business Plan')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            children: [
              AppTextField(
                controller: _summary,
                label: 'Plan Summary',
                hint: 'Enter plan summary',
                maxLines: 10,
              ),
              AppSizes.vGapMd,
              AppPrimaryButton(
                label: 'Save',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
  );
}

class FounderTeamLivePage extends StatefulWidget {
  const FounderTeamLivePage({super.key});

  @override
  State<FounderTeamLivePage> createState() => _FounderTeamLivePageState();
}

class _FounderTeamLivePageState extends State<FounderTeamLivePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _team = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await sl<ApiClientHelper>()
        .getEnvelope<List<Map<String, dynamic>>>(
          ApiEndpoints.founderTeam,
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
    _team = res.valueOrNull ?? const [];
    setState(() => _loading = false);
  }

  Future<void> _add() async {
    final name = TextEditingController();
    final role = TextEditingController();
    await showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Add team member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: name, hint: 'Name'),
            AppTextField(controller: role, hint: 'Role'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final res = await sl<ApiClientHelper>().postAction(
                ApiEndpoints.founderTeam,
                body: {'name': name.text.trim(), 'role': role.text.trim()},
              );
              if (!mounted) return;
              res.fold(
                (f) => context.showSnack(f.message),
                (_) => context.showSnack('Member added'),
              );
              if (dCtx.mounted) Navigator.pop(dCtx);
              await _load();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(
      title: const Text('Team'),
      actions: [TextButton(onPressed: _add, child: const Text('Add'))],
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                if (_team.isEmpty)
                  const AppCard(child: Text('No team members yet')),
                for (final m in _team)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: ListTile(
                      title: Text(m['name']?.toString() ?? 'Member'),
                      subtitle: Text(m['role']?.toString() ?? ''),
                    ),
                  ),
              ],
            ),
          ),
  );
}

class FounderMediaLivePage extends StatefulWidget {
  const FounderMediaLivePage({super.key});
  @override
  State<FounderMediaLivePage> createState() => _FounderMediaLivePageState();
}

class _FounderMediaLivePageState extends State<FounderMediaLivePage> {
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
          ApiEndpoints.founderDocuments,
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
      endpoint: ApiEndpoints.founderDocumentsUpload,
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
      fields: {'category': 'founder_document'},
    );
    if (!mounted) return;
    fallback.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack('Uploaded via files API'),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(
      title: const Text('Media & Documents'),
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
                  const AppCard(child: Text('No documents uploaded')),
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

class FounderAnalyticsLivePage extends StatefulWidget {
  const FounderAnalyticsLivePage({super.key});
  @override
  State<FounderAnalyticsLivePage> createState() =>
      _FounderAnalyticsLivePageState();
}

class _FounderAnalyticsLivePageState extends State<FounderAnalyticsLivePage> {
  bool _loading = true;
  Map<String, dynamic> _analytics = const {};
  List<Map<String, dynamic>> _reports = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = sl<ApiClientHelper>();
    final a = await api.get<Map<String, dynamic>>(
      ApiEndpoints.founderAnalytics,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final r = await api.getEnvelope<List<Map<String, dynamic>>>(
      ApiEndpoints.founderReports,
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
    _analytics = a.valueOrNull ?? const {};
    _reports = r.valueOrNull ?? const [];
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    appBar: AppBar(title: const Text('Founder Analytics')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                _metric('Funding Raised', _analytics['fundingRaised']),
                _metric('Investor Interests', _analytics['investorInterests']),
                _metric('Meetings', _analytics['meetings']),
                _metric('Pitch Deck Views', _analytics['pitchDeckViews']),
                _metric('Wallet', _analytics['walletBalance']),
                _metric('Subscription', _analytics['subscriptionPlan']),
                for (final rep in _reports)
                  AppCard(
                    margin: const EdgeInsets.only(top: AppSizes.sm),
                    child: Text(rep['title']?.toString() ?? 'Report'),
                  ),
              ],
            ),
          ),
  );

  Widget _metric(String label, dynamic value) => AppCard(
    child: Row(
      children: [Text(label), const Spacer(), Text(value?.toString() ?? '—')],
    ),
  );
}
