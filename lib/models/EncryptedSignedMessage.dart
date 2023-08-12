import 'dart:typed_data';

// Model to save the Encrypted Message with its signature.
class EncryptedSignedMessage {
  String encryptedMessage;
  Uint8List signature;

  EncryptedSignedMessage(
      {required this.encryptedMessage, required this.signature});
}
