/// Mirrors the backend's `MESSAGE_STATUS` constants
/// (`SENT → DELIVERED → SEEN`, per `project-context.md`). Shared by the
/// real [Message] model (Story 12) and the mock `Conversation` preview
/// (Story 10) so both speak the same status vocabulary.
enum MessageStatus { sent, delivered, seen }

MessageStatus messageStatusFromJson(String value) {
  switch (value) {
    case 'DELIVERED':
      return MessageStatus.delivered;
    case 'SEEN':
      return MessageStatus.seen;
    case 'SENT':
    default:
      return MessageStatus.sent;
  }
}

String messageStatusToJson(MessageStatus status) {
  switch (status) {
    case MessageStatus.sent:
      return 'SENT';
    case MessageStatus.delivered:
      return 'DELIVERED';
    case MessageStatus.seen:
      return 'SEEN';
  }
}
