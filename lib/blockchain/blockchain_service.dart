// import 'package:web3dart/web3dart.dart';
// import 'package:http/http.dart';

// class BlockchainService {
//   final String rpcUrl = "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID";
//   final String privateKey = "box concert act already vehicle turtle capital eight rely tissue misery access";
//   final String contractAddress = "0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8";

//   late Web3Client _client;
//   late Credentials _credentials;
//   late DeployedContract _contract;
//   late ContractFunction _saveChat, _getChatHistory;

//   BlockchainService() {
//     _client = Web3Client(rpcUrl, Client());
//     _credentials = EthPrivateKey.fromHex(privateKey);
//   }

//   Future<void> initContract() async {
//     final abi = await rootBundle.loadString("assets/chat_abi.json");
//     _contract = DeployedContract(
//       ContractAbi.fromJson(abi, "ChatHistory"),
//       EthereumAddress.fromHex(contractAddress),
//     );

//     _saveChat = _contract.function("saveChat");
//     _getChatHistory = _contract.function("getChatHistory");
//   }

//   Future<void> saveChatToBlockchain(String ipfsHash) async {
//     await _client.sendTransaction(
//       _credentials,
//       Transaction.callContract(
//         contract: _contract,
//         function: _saveChat,
//         parameters: [ipfsHash],
//       ),
//     );
//   }

//   Future<List<dynamic>> getChatHistory() async {
//     return await _client.call(
//       contract: _contract,
//       function: _getChatHistory,
//       params: [EthereumAddress.fromHex("0xAd37E469c0AfD09926c2C88B1DC6bB5c4f5912Da")],
//     );
//   }
// }
