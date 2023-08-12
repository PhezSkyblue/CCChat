import 'dart:convert';
import 'package:crypto/crypto.dart';

// Class for generating 256 bits hash code from an input String.
class HASHController {
  String generateHash(String data) {
    List<int> bytes = utf8.encode(data); // convert data to bytes
    Digest digest = sha256.convert(bytes); // generate hash
    String hash = digest.toString(); // convert digest to string
    return hash.substring(32); // Return the first 32 characters (32 bytes).
  }
}
