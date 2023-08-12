import 'dart:math';
import 'dart:typed_data';
import 'package:ccchat/models/PrivateKeyString.dart';
import 'package:ccchat/models/RSAKeyPair.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';

// Class to manage RSA functions.
class RSAController {
  // Method for generating RSA pair kays (Public and Private).
  RSAKeyPair generateRSAKeys() {
    var keyParams = RSAKeyGeneratorParameters(BigInt.from(65537), 1024, 5);

    var secureRandom = FortunaRandom();
    var random = Random.secure();

    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }

    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    var rngParams = ParametersWithRandom(keyParams, secureRandom);

    final generator = RSAKeyGenerator();
    generator.init(rngParams);
    final keyPair = generator.generateKeyPair();

    final publicKey = keyPair.publicKey as RSAPublicKey;
    final privateKey = keyPair.privateKey as RSAPrivateKey;

    return RSAKeyPair(publicKey: publicKey, privateKey: privateKey);
  }  

  String encryption(String message, RSAPublicKey publicKey){
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: publicKey));
    return encrypter.encrypt(message).base64;
  }

  String decryption(String encryptedMessage, RSAPrivateKey privateKey){
    final decrypter = encrypt.Encrypter(encrypt.RSA(privateKey: privateKey));
    return decrypter.decrypt64(encryptedMessage);
  }

/*
  /* 
    Method to encrypt a message using the public RSA key and sign it using 
    the private RSA key.
  */
  EncryptedSignedMessage encryptAndSignMessage(String message,
      RSAPublicKey publicKey, RSAPrivateKey privateKey) {
    String encryptedMessage = encryption(message, publicKey);

    final signature = signMessage(privateKey, encryptedMessage);

    return EncryptedSignedMessage(
        encryptedMessage: encryptedMessage, signature: signature);
  }

  /* 
    Method to encrypt a message using the private RSA key and verify its 
    signature using the public RSA key.
  */
  String verifyAndDecryptMessage(String encryptedMessage, Uint8List signature,
    RSAPublicKey publicKey, RSAPrivateKey privateKey) {

    if (verifySignature(publicKey, encryptedMessage, signature)) {
      return decryption(encryptedMessage, privateKey);
    } else {
      return "";
    }
  }

  // Method to sign messages with the private RSA key.
  Uint8List signMessage(PrivateKey privateKey, String message) {
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');

    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final bytes = Uint8List.fromList(message.codeUnits);

    return signer.generateSignature(bytes).bytes;
  }

  // Method to verify the signature of the message with the public RSA key.
  bool verifySignature(
      PublicKey publicKey, String message, Uint8List signature) {
    /*
      The string '0609608648016503040201' is and OID that identifies the
      algorithm used to sign the message in pointycastle library (SHA-256).
    */
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');

    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    final bytes = Uint8List.fromList(message.codeUnits);

    return verifier.verifySignature(bytes, RSASignature(signature));
  }
*/
  RSAPrivateKey getRSAPrivateKey(PrivateKeyString key) {
    return RSAPrivateKey(
      BigInt.parse(key.modulus), 
      BigInt.parse(key.privateExponent), 
      BigInt.parse(key.p), 
      BigInt.parse(key.q),
    );
  }

  RSAPublicKey getRSAPublicKey(String exponent, String modulus){
    return RSAPublicKey(
      BigInt.parse(modulus), 
      BigInt.parse(exponent), 
    );
  }

/*
  String encryptPrivateKey(RSAPrivateKey privateKeyToEncrypt, RSAPublicKey publicKey) {
    final cipher = AsymmetricBlockCipher('RSA/PKCS1');
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final privateKeyBytes = privateKeyToEncrypt.privateExponent!.toBytes();
    final encryptedBytes = cipher.process(privateKeyBytes);
    final encryptedPrivateKey = base64.encode(encryptedBytes);

    return encryptedPrivateKey;
  }

  RSAPrivateKey decryptPrivateKey(String encryptedPrivateKey, RSAPrivateKey privateKey) {
    final cipher = AsymmetricBlockCipher('RSA/PKCS1');
    cipher.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final encryptedBytes = base64.decode(encryptedPrivateKey);
    final decryptedBytes = cipher.process(encryptedBytes);

    final privateExponent = BigInt.from(decryptedBytes);
    final privateKeyParams = RSAPrivateKeyParameters(privateKey.modulus, privateExponent);

    return RSAPrivateKey(privateKeyParams);
  }*/

  /*
  PrivateKeyString encryptPrivateKey(PrivateKeyString privateKey, RSAPublicKey publicKey){
    return PrivateKeyString(
      privateExponent: encryption(privateKey.privateExponent, publicKey),
      modulus: encryption(privateKey.modulus, publicKey),
      p: encryption(privateKey.p, publicKey), 
      q: encryption(privateKey.q, publicKey), 
    );
  }

  PrivateKeyString decryptPrivateKey(PrivateKeyString encryptedPrivateKey, RSAPrivateKey privateKey){
    return PrivateKeyString(
      privateExponent: decryption(encryptedPrivateKey.privateExponent, privateKey),
      modulus: decryption(encryptedPrivateKey.modulus, privateKey),
      p: decryption(encryptedPrivateKey.p, privateKey),
      q: decryption(encryptedPrivateKey.q, privateKey)
    );
  }
  */
}
