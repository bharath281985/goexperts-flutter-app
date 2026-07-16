import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../proposals/domain/entities/proposal.dart';
import '../../domain/repositories/client_proposal_repository.dart';

part 'client_proposal_event.dart';
part 'client_proposal_state.dart';

enum ClientProposalAction { shortlist, reject, interview, accept, message }

/// Manages client-side proposal lists and status actions.
class ClientProposalBloc extends Bloc<ClientProposalEvent, ClientProposalState> {
  ClientProposalBloc(this._repository) : super(const ClientProposalState()) {
    on<ClientProposalsLoadRequested>(_onLoad);
    on<ClientProjectProposalsLoadRequested>(_onLoadProject);
    on<ClientProposalShortlistRequested>(_onShortlist);
    on<ClientProposalRejectRequested>(_onReject);
    on<ClientProposalInterviewRequested>(_onInterview);
    on<ClientProposalAcceptRequested>(_onAccept);
    on<ClientProposalMessageRequested>(_onMessage);
  }

  final ClientProposalRepository _repository;

  Future<void> _onLoad(
    ClientProposalsLoadRequested event,
    Emitter<ClientProposalState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading, clearError: true));
    final result = await _repository.getProposals(event.params);
    _emitList(emit, result);
  }

  Future<void> _onLoadProject(
    ClientProjectProposalsLoadRequested event,
    Emitter<ClientProposalState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading, clearError: true));
    final result = await _repository.getProjectProposals(
      event.projectId,
      event.params,
    );
    _emitList(emit, result);
  }

  Future<void> _onShortlist(
    ClientProposalShortlistRequested event,
    Emitter<ClientProposalState> emit,
  ) => _runAction(
        emit,
        event.proposalId,
        ClientProposalAction.shortlist,
        () => _repository.shortlist(event.proposalId),
      );

  Future<void> _onReject(
    ClientProposalRejectRequested event,
    Emitter<ClientProposalState> emit,
  ) => _runAction(
        emit,
        event.proposalId,
        ClientProposalAction.reject,
        () => _repository.reject(event.proposalId),
      );

  Future<void> _onInterview(
    ClientProposalInterviewRequested event,
    Emitter<ClientProposalState> emit,
  ) => _runAction(
        emit,
        event.proposalId,
        ClientProposalAction.interview,
        () => _repository.moveToInterview(event.proposalId),
      );

  Future<void> _onAccept(
    ClientProposalAcceptRequested event,
    Emitter<ClientProposalState> emit,
  ) => _runAction(
        emit,
        event.proposalId,
        ClientProposalAction.accept,
        () => _repository.accept(event.proposalId),
      );

  Future<void> _onMessage(
    ClientProposalMessageRequested event,
    Emitter<ClientProposalState> emit,
  ) async {
    emit(state.copyWith(
      actionInFlight: ClientProposalAction.message,
      actionProposalId: event.proposalId,
      clearError: true,
    ));
    final result = await _repository.sendMessage(event.proposalId, event.message);
    result.fold(
      (f) => emit(state.copyWith(
        actionInFlight: null,
        actionProposalId: null,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(
        actionInFlight: null,
        actionProposalId: null,
        successMessage: 'Message sent',
      )),
    );
  }

  void _emitList(Emitter<ClientProposalState> emit, Result<Paginated<Proposal>> result) {
    result.fold(
      (f) => emit(state.copyWith(
        status: ViewStatus.failure,
        errorMessage: f.message,
      )),
      (page) => emit(state.copyWith(
        status: page.items.isEmpty ? ViewStatus.empty : ViewStatus.success,
        proposals: page.items,
        page: page,
      )),
    );
  }

  Future<void> _runAction(
    Emitter<ClientProposalState> emit,
    String proposalId,
    ClientProposalAction action,
    Future<Result<Proposal>> Function() call,
  ) async {
    emit(state.copyWith(
      actionInFlight: action,
      actionProposalId: proposalId,
      clearError: true,
      clearSuccess: true,
    ));
    final result = await call();
    result.fold(
      (f) => emit(state.copyWith(
        actionInFlight: null,
        actionProposalId: null,
        errorMessage: f.message,
      )),
      (proposal) {
        final updated = state.proposals
            .map((p) => p.id == proposal.id ? proposal : p)
            .toList();
        emit(state.copyWith(
          actionInFlight: null,
          actionProposalId: null,
          proposals: updated,
          selectedProposal:
              state.selectedProposal?.id == proposal.id ? proposal : state.selectedProposal,
          successMessage: _successLabel(action),
        ));
      },
    );
  }

  String _successLabel(ClientProposalAction action) {
    switch (action) {
      case ClientProposalAction.shortlist:
        return 'Proposal shortlisted';
      case ClientProposalAction.reject:
        return 'Proposal rejected';
      case ClientProposalAction.interview:
        return 'Moved to interview';
      case ClientProposalAction.accept:
        return 'Proposal accepted';
      case ClientProposalAction.message:
        return 'Message sent';
    }
  }
}
