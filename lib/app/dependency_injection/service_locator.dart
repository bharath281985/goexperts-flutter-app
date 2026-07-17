import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/session_handler.dart';
import '../../core/auth/token_role_helper.dart';
import '../../core/connectivity/connectivity_cubit.dart';
import '../../core/network/api_client_helper.dart';
import '../../core/network/app_runtime_config_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/file_upload_helper.dart';
import '../../core/network/network_info.dart';
import '../../core/notifications/device_token_registration_service.dart';
import '../../core/notifications/push_notification_service.dart';
import '../../core/payments/payment_checkout_service.dart';
import '../../core/realtime/chat_socket_service.dart';
import '../../core/services/app_update_service.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/device_info_helper.dart';

import '../../features/auth/data/datasources/social_auth_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/client_dashboard/data/datasources/client_proposal_remote_datasource.dart';
import '../../features/client_dashboard/data/repositories/client_proposal_repository_impl.dart';
import '../../features/client_dashboard/domain/repositories/client_proposal_repository.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/proposals/data/repositories/proposal_repository_impl.dart';
import '../../features/proposals/domain/repositories/proposal_repository.dart';
import '../../features/freelancer_dashboard/data/repositories/freelancer_repository_impl.dart';
import '../../features/freelancer_dashboard/data/repositories/freelancer_profile_repository_impl.dart';
import '../../features/freelancer_dashboard/data/repositories/freelancer_task_repository_impl.dart';
import '../../features/freelancer_dashboard/data/repositories/portfolio_repository_impl.dart';
import '../../features/freelancer_dashboard/domain/repositories/freelancer_repository.dart';
import '../../features/freelancer_dashboard/domain/repositories/freelancer_profile_repository.dart';
import '../../features/freelancer_dashboard/domain/repositories/freelancer_task_repository.dart';
import '../../features/freelancer_dashboard/domain/repositories/portfolio_repository.dart';
import '../../features/client_dashboard/data/repositories/company_repository_impl.dart';
import '../../features/client_dashboard/domain/repositories/company_repository.dart';
import '../../features/startup_ideas/data/repositories/startup_repository_impl.dart';
import '../../features/startup_ideas/domain/repositories/startup_repository.dart';
import '../../features/investor_dashboard/data/repositories/investor_repository_impl.dart';
import '../../features/investor_dashboard/domain/repositories/investor_repository.dart';
import '../../features/founder_dashboard/data/repositories/founder_repository_impl.dart';
import '../../features/founder_dashboard/domain/repositories/founder_repository.dart';
import '../../features/messages/data/repositories/message_repository_impl.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../features/meetings/data/repositories/meeting_repository_impl.dart';
import '../../features/meetings/domain/repositories/meeting_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/profile/data/repositories/review_repository_impl.dart';
import '../../features/profile/domain/repositories/review_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/documents/data/repositories/document_repository_impl.dart';
import '../../features/documents/domain/repositories/document_repository.dart';
import '../../features/master_data/data/repositories/master_data_repository_impl.dart';
import '../../features/master_data/domain/repositories/master_data_repository.dart';

/// Tiny hand-rolled service locator (avoids an extra dependency).
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  final Map<Type, Object> _singletons = {};

  T get<T extends Object>() {
    final obj = _singletons[T];
    if (obj == null) {
      throw StateError(
        'Service $T not registered. Did you call configureDependencies()?',
      );
    }
    return obj as T;
  }

  void _register<T extends Object>(T instance) => _singletons[T] = instance;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final localStorage = LocalStorage(prefs);
    final secureStorage = SecureStorage();
    final sessionHandler = SessionHandler();
    final networkInfo = NetworkInfoImpl();
    final dioClient = DioClient(secureStorage, sessionHandler);
    final apiClient = ApiClientHelper(dioClient);
    final fileUploadHelper = FileUploadHelper(dioClient);
    final pushService = FirebasePushNotificationService();
    final deviceInfo = DeviceInfoHelper(localStorage, pushService);
    final deviceTokenRegistration = DeviceTokenRegistrationService(
      apiClient,
      deviceInfo,
      pushService,
    );
    final paymentCheckout = PaymentCheckoutService(apiClient);
    final chatSocket = ChatSocketService(secureStorage);
    final socialAuth = SocialAuthService();
    final tokenRoleHelper = TokenRoleHelper(secureStorage);
    final appUpdateService = AppUpdateService(apiClient);

    sessionHandler.onTokenRefreshed = () => chatSocket.reconnectWithToken();

    _register<LocalStorage>(localStorage);
    _register<SecureStorage>(secureStorage);
    _register<SessionHandler>(sessionHandler);
    _register<NetworkInfo>(networkInfo);
    _register<ConnectivityCubit>(ConnectivityCubit(networkInfo));
    _register<DioClient>(dioClient);
    _register<ApiClientHelper>(apiClient);
    _register<FileUploadHelper>(fileUploadHelper);
    _register<AppRuntimeConfigService>(AppRuntimeConfigService(apiClient));
    _register<AppUpdateService>(appUpdateService);
    _register<PushNotificationService>(pushService);
    _register<DeviceTokenRegistrationService>(deviceTokenRegistration);
    _register<PaymentCheckoutService>(paymentCheckout);
    _register<ChatSocketService>(chatSocket);
    _register<SocialAuthService>(socialAuth);
    _register<DeviceInfoHelper>(deviceInfo);
    _register<TokenRoleHelper>(tokenRoleHelper);

    final authRemote = AuthRemoteDatasource(
      apiClient,
      secureStorage,
      deviceInfo,
    );

    _register<AuthRepository>(
      AuthRepositoryImpl(
        remote: authRemote,
        secureStorage: secureStorage,
        localStorage: localStorage,
        socialAuth: socialAuth,
        chatSocket: chatSocket,
      ),
    );
    _register<ClientProposalRepository>(
      ClientProposalRepositoryImpl(ClientProposalRemoteDatasource(apiClient)),
    );
    _register<ProjectRepository>(
      ProjectRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<ProposalRepository>(ProposalRepositoryImpl(apiClient));
    _register<FreelancerRepository>(
      FreelancerRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<FreelancerProfileRepository>(
      FreelancerProfileRepositoryImpl(apiClient, fileUploadHelper),
    );
    _register<FreelancerTaskRepository>(
      FreelancerTaskRepositoryImpl(apiClient, fileUploadHelper),
    );
    _register<DocumentRepository>(
      DocumentRepositoryImpl(apiClient, fileUploadHelper),
    );
    _register<PortfolioRepository>(PortfolioRepositoryImpl(apiClient));
    _register<CompanyRepository>(
      CompanyRepositoryImpl(apiClient, fileUploadHelper),
    );
    _register<StartupRepository>(
      StartupRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<InvestorRepository>(
      InvestorRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<FounderRepository>(FounderRepositoryImpl(apiClient));
    _register<MessageRepository>(
      MessageRepositoryImpl(
        apiClient,
        tokenRoleHelper,
        fileUploadHelper,
        chatSocket,
      ),
    );
    _register<MeetingRepository>(
      MeetingRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<WalletRepository>(
      WalletRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<SubscriptionRepository>(
      SubscriptionRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<NotificationRepository>(
      NotificationRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<CatalogRepository>(CatalogRepositoryImpl(apiClient));
    _register<MasterDataRepository>(MasterDataRepositoryImpl());
    _register<ReviewRepository>(
      ReviewRepositoryImpl(apiClient, tokenRoleHelper),
    );
    _register<SettingsRepository>(
      SettingsRepositoryImpl(apiClient, tokenRoleHelper),
    );
  }
}

T sl<T extends Object>() => ServiceLocator.instance.get<T>();

Future<void> configureDependencies() => ServiceLocator.instance.init();
