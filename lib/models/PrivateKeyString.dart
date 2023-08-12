// Model to save the private Key with its String components.
class PrivateKeyString {
  String privateExponent;
  String modulus;
  String p;
  String q;

  PrivateKeyString(
      {required this.privateExponent,
      required this.modulus,
      required this.p,
      required this.q});
}
