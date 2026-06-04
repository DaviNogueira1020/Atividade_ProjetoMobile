
import 'package:dart_frog/dart_frog.dart';

import 'package:backend/enums/category_enum.dart';
import 'package:backend/enums/priority_enum.dart';
import 'package:backend/enums/status_enum.dart';
import 'package:backend/exceptions/business_exception.dart';
import 'package:backend/models/ticket.dart';
import 'package:backend/repositories/ticket_repository.dart';
import 'package:backend/services/ticket_service.dart';

Future<Response> onRequest(RequestContext context, String id) async{
  final request = context.request;

  switch (request.method){
    case HttpMethod.get:
      return _getTicket(id);

    case HttpMethod.put:
      return _updateTicket(request, id);

    case HttpMethod.delete:
      return _deleteTicket(id);

    // ignore: no_default_cases
    default:
      return Response.json(
        statusCode: 405,
        body: {
          'error': 'Método não permitido',
        },
      );
  }
}

Response _getTicket(String id){
  final repository = TicketRepository();

  final service = TicketService(repository);

  final ticket = service.getTicketById(int.parse(id));

  if(ticket == null){
    return Response.json(
      statusCode: 404,
      body: {
        'error': 'Chamado não encontrado',
      },
    );
  }

  return Response.json(
    body: ticket.toJson(),
  );
}

Response _deleteTicket(String id){
  try{
    final repository = TicketRepository();

    final service = TicketService(repository);

    service.deleteTicket(int.parse(id));

    return Response.json(
      body: {
        'message':
            'Chamado removido com sucesso',
      },
    );
  } on BusinessException catch (e) {
    return Response.json(
      statusCode: 404,
      body: {
        'error': e.message,
      },
    );
  }
}

Future<Response> _updateTicket(Request request, String id) async{
  try{
    final body = await request.json() as Map<String, dynamic>;

    final repository = TicketRepository();

    final service = TicketService(repository);

    final existing = service.getTicketById(int.parse(id));

    if(existing == null){
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Chamado não encontrado',
        },
      );
    }

    final updated = existing.copyWith(
      title: body['title'] as String?,
      description: body['description'] as String?,
      category: body['category'] != null ?
      Category.fromString(body['category'] as String) : null,
      priority: body['priority'] != null ?
      Priority.fromString(body['priority'] as String) : null,
      neighborhood: body['neighborhood'] as String?,
      responsible: body['responsible'] as String?,
      status: body['status'] != null ?
      Status.fromString(body['status'] as String): null,
    );

    service.updateTicket(updated);

    return Response.json(
      body: updated.toJson(),
    );
  } on BusinessException catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': e.message,
      },
    );
  }
}