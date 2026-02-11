import 'package:share_plus/share_plus.dart';

class SocialService {
  Future<void> share(String text) async {
    await Share.share(text);
  }
}
