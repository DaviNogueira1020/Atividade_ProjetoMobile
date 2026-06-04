import 'package:backend/models/dashboard.dart';

import '../exceptions/business_exception.dart';
import '../models/ticket.dart';
import '../repositories/ticket_repository.dart';
import '../enums/status_enum.dart';

class TicketService{
  final TicketRepository _repository;

  TicketService(this._repository);

  Ticket createTicket(Ticket ticket){
    if(ticket.title.trim().isEmpty){
      throw const BusinessException('Título é obrigatório');
    }

    if(ticket.description.trim().isEmpty){
      throw const BusinessException('Descrição é obrigatória');
    }

    if(ticket.neighborhood.trim().isEmpty){
      throw const BusinessException('Bairro é obrigatório');
    }

    final existing = _repository.findByTitle(ticket.title);

    if(existing != null){
      throw const BusinessException('Título já cadastrado');
    }

    final id = _repository.create(ticket);

    return ticket.copyWith(
      id: id,
    );
  }

  void updateTicket(Ticket ticket){
    if(ticket.id == null){
      throw const BusinessException('ID do chamado é obrigatório');
    }
    
    final existing = _repository.findById(ticket.id!);

    if(existing == null){
      throw const BusinessException('Chamado não encontrado');
    }

    if(existing.status == Status.concluido){
      throw const BusinessException('Chamados concluídos não podem ser editados');
    }

    final ticketWithSameTitle = _repository.findByTitle(ticket.title);
    
    if(ticketWithSameTitle != null && ticketWithSameTitle.id != ticket.id){
      throw const BusinessException('Título já cadastrado');
    }

    _repository.update(ticket);
  }
  
  void deleteTicket(int id){
    final existing = _repository.findById(id);

    if(existing == null){
      throw const BusinessException('Chamado não encontrado');
    }

    _repository.delete(id);
  }

  List<Ticket> getAllTickets(){
    return _repository.findAll();
  }

  Ticket? getTicketById(int id){
    return _repository.findById(id);
  }

  Dashboard getDashboard(){
    final total = _repository.countAll();

    final critical = _repository.countCritical();

    return Dashboard(
      total: total,
      open: _repository.countByStatus(Status.aberto.index),
      inProgress: _repository.countByStatus(Status.emAndamento.index),
      completed: _repository.countByStatus(Status.concluido.index),
      critical: critical,
      hasAlert: critical > 5,
    );
  }
}

