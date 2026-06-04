import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'package:backend/repositories/ticket_repository.dart';
import 'package:backend/services/ticket_service.dart';

Future<Response> onRequest(RequestContext context) async{
  final request = context.request;

  if(request.method != HttpMethod.get){
      return Response.json(
      statusCode: 405,
      body: {
        'error': 'Método não permitido',
      },
    );
  }

  return _getTickets();
}

Response _getTickets() {
  final repository = TicketRepository();
  final service = TicketService(repository);

  final tickets = service.getAllTickets();

  return Response.json(
    body: tickets
        .map((ticket) => ticket.toJson())
        .toList(),
  );
}