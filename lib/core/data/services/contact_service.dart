import 'package:url_launcher/url_launcher.dart';

class ContactService {
  /// Open WhatsApp chat with the provided phone number
  Future<void> openWhatsapp(String phone, {String message = ""}) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open WhatsApp");
    }
  }

  /// Call the provided phone number
  Future<void> callToPhone(String phone) async {
    final url = Uri.parse("tel:$phone");

    if (!await launchUrl(url)) {
      throw Exception("Could not call phone number");
    }
  }

  /// Open Instagram profile using URL or username
  Future<void> openInstagram(String input) async {
    final isUrl = input.startsWith('http://') || input.startsWith('https://');
    final url = Uri.parse(isUrl ? input : "https://instagram.com/$input");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open Instagram profile");
    }
  }
}
