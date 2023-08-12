import 'package:basic_utils/basic_utils.dart';

// Model to save the RSA pair of keys (Public and Private).
class RSAKeyPair {
  RSAPublicKey publicKey;
  RSAPrivateKey privateKey;

  RSAKeyPair({required this.publicKey, required this.privateKey});
}
