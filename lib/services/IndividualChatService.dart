import '../models/IndividualChat.dart';

abstract class IndividualChatService {
  Future<IndividualChat?> createChatIndividual(String idUser, String idOtherUser);

  Future<IndividualChat?> getChatByID(String id);

  Future<List<IndividualChat>> getListOfChats(String id);

  Future<bool> updateNameUser(String id, String? name);
}
