String? accessScanReasonLabel(String? reasonCode) {
  switch (reasonCode?.trim().toUpperCase()) {
    case 'EVENT_ACCESS_DENIED':
      return 'Sin acceso al evento';
    case 'TICKET_EVENT_MISMATCH':
      return 'Evento incorrecto';
    case 'TICKET_NOT_FOUND':
      return 'Ticket no encontrado';
    case 'TICKET_STATUS_INVALID':
      return 'Estado no válido';
    case 'ALREADY_CHECKED_IN':
      return 'Ya registrado';
    case 'CHECKED_IN':
      return 'Acceso registrado';
    case 'UNRESOLVED_SCAN_RESULT':
      return 'Resultado no resuelto';
    case 'TICKET_VALIDITY_NOT_STARTED':
      return 'Aún no está dentro del horario válido';
    case 'TICKET_VALIDITY_EXPIRED':
      return 'El horario válido ya ha terminado';
    case 'CHECKED_IN_OUTSIDE_VALIDITY':
      return 'Acceso registrado fuera del horario válido';
    case 'CHECK_IN_REVERSED':
      return 'Acceso desmarcado';
    case 'TICKET_NOT_CHECKED_IN':
      return 'La entrada no tiene el acceso marcado';
    case 'TICKET_NOT_REDEEMABLE':
      return 'Esta entrada no permite consumir extras';
    case 'ADD_ON_ASSIGNMENT_NOT_FOUND':
      return 'Extra no encontrado';
    case 'ADD_ON_QUANTITY_UNAVAILABLE':
      return 'No quedan unidades disponibles de este extra';
    case 'ADD_ON_EDIT_CONFLICT':
      return 'Los extras han cambiado. Cierra y vuelve a abrir para actualizar';
    case 'ADD_ON_EDIT_FAILED':
    case 'ADD_ON_REDEMPTION_FAILED':
      return 'No se pudieron guardar los extras';
    case 'DUPLICATE_ADD_ON_ASSIGNMENT':
      return 'El extra está repetido';
    case 'REDEMPTION_NOT_FOUND':
      return 'Consumo no encontrado';
    case 'INVALID_REDEMPTION':
      return 'El consumo no es válido';
    case 'AUTH_REQUIRED':
      return 'Inicia sesión de nuevo';
    case 'FORBIDDEN':
      return 'No tienes permiso para esta operación';
    case 'EVENT_NOT_FOUND':
      return 'Evento no encontrado';
    case 'EVENT_NOT_SELECTED':
      return 'Selecciona un evento para continuar';
    case 'INVALID_EVENT_ID':
      return 'El evento no es válido';
    case 'INVALID_TICKET_ID':
      return 'La entrada no es válida';
    case 'INVALID_TICKET_CONTEXT':
      return 'La entrada no corresponde a esta operación';
    case 'INVALID_INPUT':
      return 'El código de entrada no es válido';
    case 'INVALID_INPUT_KIND':
      return 'El formato del código no es válido';
    case 'INVALID_SOURCE':
      return 'El origen de la operación no es válido';
    case 'INVALID_RESULT_CODE':
      return 'El filtro de resultados no es válido';
    case 'INVALID_QUERY':
      return 'La búsqueda no es válida';
    case 'INVALID_RESPONSE':
      return 'No se pudo leer la respuesta. Inténtalo de nuevo';
    case 'CODE_EXPIRED':
      return 'El código ha caducado';
    case 'CODE_NOT_FOUND':
      return 'Código no encontrado';
    case 'INVALID_CODE':
      return 'El código no es válido';
    case 'PROFILE_NOT_FOUND':
      return 'Perfil no encontrado';
    case 'INVALID_DISPLAY_NAME':
      return 'El nombre no es válido';
    case 'INVALID_EMAIL':
      return 'El correo electrónico no es válido';
    case 'INVALID_USERNAME':
      return 'El nombre de usuario no es válido';
    case 'USERNAME_TAKEN':
      return 'El nombre de usuario ya está en uso';
    case null:
    case '':
      return null;
    default:
      return 'No se pudo completar la operación';
  }
}
