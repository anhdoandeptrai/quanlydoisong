import 'dart:convert';
import 'package:http/http.dart' as http;

class IPFSService {
  final String ipfsGateway = "https://api.pinata.cloud/pinning/pinJSONToIPFS";
  final String apiKey = "677dbc395b5a0b73e70a"; // API Key từ Pinata

  Future<String> uploadChatToIPFS(Map<String, dynamic> chatData) async {
    final response = await http.post(
      Uri.parse(ipfsGateway),
      headers: {
        "pinata_api_key": apiKey,
        "Content-Type": "application/json",
      },
      body: jsonEncode({"pinataContent": chatData}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["IpfsHash"]; // Trả về IPFS hash
    } else {
      throw Exception("Upload thất bại");
    }
  }
}
