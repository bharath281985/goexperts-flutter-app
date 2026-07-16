part of 'client_proposal_bloc.dart';

class ClientProposalState extends Equatable {
  const ClientProposalState({
    this.status = ViewStatus.initial,
    this.proposals = const [],
    this.page,
    this.selectedProposal,
    this.actionInFlight,
    this.actionProposalId,
    this.errorMessage,
    this.successMessage,
  });

  final ViewStatus status;
  final List<Proposal> proposals;
  final Paginated<Proposal>? page;
  final Proposal? selectedProposal;
  final ClientProposalAction? actionInFlight;
  final String? actionProposalId;
  final String? errorMessage;
  final String? successMessage;

  bool isActionLoading(ClientProposalAction action, String proposalId) =>
      actionInFlight == action && actionProposalId == proposalId;

  ClientProposalState copyWith({
    ViewStatus? status,
    List<Proposal>? proposals,
    Paginated<Proposal>? page,
    Proposal? selectedProposal,
    ClientProposalAction? actionInFlight,
    String? actionProposalId,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClientProposalState(
      status: status ?? this.status,
      proposals: proposals ?? this.proposals,
      page: page ?? this.page,
      selectedProposal: selectedProposal ?? this.selectedProposal,
      actionInFlight: actionInFlight,
      actionProposalId: actionProposalId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        proposals,
        page,
        selectedProposal,
        actionInFlight,
        actionProposalId,
        errorMessage,
        successMessage,
      ];
}
