import 'package:dart_frog/dart_frog.dart';

import 'package:backend/repositories/ticket_repository.dart';
import 'package:backend/services/ticket_service.dart';

Response onRequest(RequestContext context){
  final repository = TicketRepository();

  final service = TicketService(repository);

  final dashboard = service.getDashboard();

  return Response.json(body: dashboard.toJson());
}