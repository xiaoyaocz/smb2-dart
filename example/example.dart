import 'package:smb2/smb2.dart';

void main() async {
  final uri = Uri.parse('smb://guest:@192.168.31.110/sharedisk');
  final smb = SMB(uri, debug: true);
  await smb.connect();

  final files = await smb.readDirectory('/');
  print(files);

  smb.disconnect();
}
