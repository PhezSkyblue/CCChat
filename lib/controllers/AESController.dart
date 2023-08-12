import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/export.dart';
import '../models/PrivateKeyString.dart';


// Class to manage AES functions.
class AESController {
  // Method to encrypt a plainText using a key and a Initial Vector.
  String encrypt(String keyString, String plainText, String ivString) {
    final iv = IV.fromUtf8(ivString.substring(16));
    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cfb64));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // Method to decrypt an encrypted text using a key and an Initial Vector.
  String decrypt(String keyString, String encrypted, String ivString) {
    final iv = IV.fromUtf8(ivString.substring(16));
    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cfb64));
    final decrypted = encrypter.decrypt64(encrypted, iv: iv);
    return decrypted;
  }

  String generateRandomPassword(int length) {
    final random = Random.secure();
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_-+=<>?";
    
    return List.generate(length, (index) {
      final randomIndex = random.nextInt(charset.length);
      return charset[randomIndex];
    }).join('');
  }

  /*
    Method to encrypt the private RSA key using the hash code as the key, 
    the public RSA key as the Initial Vector. 
  */
  PrivateKeyString privateKeyEncryption(
      String hash, RSAPublicKey myPublicKey, RSAPrivateKey myPrivateKey) {
    String encryptedModulus = encrypt(hash, myPrivateKey.modulus!.toString(),
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    String encryptedPrivatedExponent = encrypt(
        hash,
        myPrivateKey.privateExponent!.toString(),
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    String encryptedP = encrypt(hash, myPrivateKey.p!.toString(),
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    String encryptedQ = encrypt(hash, myPrivateKey.q!.toString(),
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    return PrivateKeyString(
        privateExponent: encryptedPrivatedExponent,
        modulus: encryptedModulus,
        p: encryptedP,
        q: encryptedQ);
  }

  /*
    Method to decrypt the private RSA key using the hash code as the key, 
    the public RSA key as the Initial Vector. 
  */
  PrivateKeyString privateKeyDecryption(
    String hash,
    RSAPublicKey myPublicKey,
    PrivateKeyString privateKeyString,
  ) {
    String decryptedModulus = decrypt(hash, privateKeyString.modulus,
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    String decryptedPrivatedExponent = decrypt(
        hash,
        privateKeyString.privateExponent,
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    String decryptedP = decrypt(hash, privateKeyString.p,
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

    String decryptedQ = decrypt(hash, privateKeyString.q,
        myPublicKey.exponent!.toUnsigned(32).toInt().toString());

  return PrivateKeyString(
        privateExponent: decryptedPrivatedExponent,
        modulus: decryptedModulus,
        p: decryptedP,
        q: decryptedQ);

/*
    return RSAPrivateKey(
        BigInt.parse(decryptedModulus),
        BigInt.parse(decryptedPrivatedExponent),
        BigInt.parse(decryptedP),
        BigInt.parse(decryptedQ));*/
  }
}
