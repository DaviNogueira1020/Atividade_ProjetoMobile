import 'package:dart_frog/dart_frog.dart';

import 'package:backend/enums/category_enum.dart';
import 'package:backend/enums/priority_enum.dart';
import 'package:backend/enums/status_enum.dart';
import 'package:backend/exceptions/business_exception.dart';
import 'package:backend/models/ticket.dart';
import 'package:backend/repositories/ticket_repository.dart';
import 'package:backend/services/ticket_service.dart';

Future<Response> onRequest(RequestContext context) async{
  final request = context.request;

  switch (request.method) {
    case HttpMethod.get:
      return _getTickets(request);

    case HttpMethod.post:
      return _createTicket(request);

    // ignore: no_default_cases
    default:
      return Response.json(
        statusCode: 405,
        body: {'error': 'Método não permitido'}
      );
  }
}

Response _getTickets(Request request){
  final repository = TicketRepository();
  final service = TicketService(repository);

  final search = request.uri.queryParameters['search'];
  final neighborhood = request.uri.queryParameters['bairro'];

  if(search != null && search.isNotEmpty){
    final tickets = service.searchTickets(search);

    return Response.json(
      body: tickets
        .map((ticket) => ticket.toJson())
        .toList(),  
    );
  }

  if(neighborhood != null && neighborhood.isNotEmpty){
    final tickets = service.getTicketsByNeighborhood(neighborhood);

    return Response.json(
      body: tickets
        .map((ticket) => ticket.toJson())
        .toList(),  
    );
  }

  final tickets = service.getAllTickets();

  return Response.json(
    body: tickets
        .map((ticket) => ticket.toJson())
        .toList(),
  );
}

Future<Response> _createTicket(Request request) async{
  try{
    final body = await request.json() as Map<String, dynamic>;
    
    final ticket = Ticket(
      title: body['title'] as String,
      description: body['description'] as String,
      category: Category.fromString(body['category'] as String),
      priority: Priority.fromString(body['priority'] as String),
      neighborhood: body['neighborhood'] as String,
      responsible: body['responsible'] as String,
      openedAt: DateTime.now(),
      status: Status.aberto,
    );

    final repository = TicketRepository();

    final service = TicketService(repository);

    final created = service.createTicket(ticket);

    return Response.json(
      statusCode: 201,
      body: created.toJson(),
    );
  } on BusinessException catch (e){
    return Response.json(
      statusCode: 400,
      body: {
        'error': e.message, //Change it before production
      },
    );
  } catch (e){
    return Response.json(
      statusCode: 500,
      body: {
        'error': e.toString(), //Change it before production
      },
    );
  }
}