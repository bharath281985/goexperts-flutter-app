part of 'client_proposal_bloc.dart';

sealed class ClientProposalEvent extends Equatable {
  const ClientProposalEvent();

  @override
  List<Object?> get props => [];
}

class ClientProposalsLoadRequested extends ClientProposalEvent {
  const ClientProposalsLoadRequested([this.params = const QueryParams()]);
  final QueryParams params;

  @override
  List<Object?> get props => [params];
}

class ClientProjectProposalsLoadRequested extends ClientProposalEvent {
  const ClientProjectProposalsLoadRequested({
    required this.projectId,
    this.params = const QueryParams(),
  });

  final String projectId;
  final QueryParams params;

  @override
  List<Object?> get props => [projectId, params];
}

class ClientProposalShortlistRequested extends ClientProposalEvent {
  const ClientProposalShortlistRequested(this.proposalId);
  final String proposalId;

  @override
  List<Object?> get props => [proposalId];
}

class ClientProposalRejectRequested extends ClientProposalEvent {
  const ClientProposalRejectRequested(this.proposalId);
  final String proposalId;

  @override
  List<Object?> get props => [proposalId];
}

class ClientProposalInterviewRequested extends ClientProposalEvent {
  const ClientProposalInterviewRequested(this.proposalId);
  final String proposalId;

  @override
  List<Object?> get props => [proposalId];
}

class ClientProposalAcceptRequested extends ClientProposalEvent {
  const ClientProposalAcceptRequested(this.proposalId);
  final String proposalId;

  @override
  List<Object?> get props => [proposalId];
}

class ClientProposalMessageRequested extends ClientProposalEvent {
  const ClientProposalMessageRequested({
    required this.proposalId,
    required this.message,
  });

  final String proposalId;
  final String message;

  @override
  List<Object?> get props => [proposalId, message];
}
