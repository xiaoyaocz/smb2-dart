import 'dart:typed_data';
import 'dart:convert';
import './common/flags.dart' as flags;

/// Data class for all information contained in the type 2 response.
///
/// Used to calculate the type 3 response.
class Type2Message {
  late Uint8List signature;
  late int type;
  late int targetNameLength;
  late int targetNameMaxLength;
  late int targetNameOffset;
  late Uint8List targetName;
  late int negotiateFlags;
  late Uint8List serverChallenge;
  late Uint8List reserved;
  late int targetInfoLength;
  late int targetInfoMaxLength;
  late int targetInfoOffset;
  late Uint8List targetInfo;

  @override
  String toString() {
    return "---BEGIN TYPE 2 MESSAGE---\n"
        "Signature:        ${ascii.decode(signature.toList(), allowInvalid: true)}\n"
        "  Raw:            ${signature.toList()}\n"
        "Type:             $type\n"
        "Target Name:      ${ascii.decode(targetName.toList(), allowInvalid: true)}\n"
        "  Length:         $targetNameLength\n"
        "  Max Length:     $targetNameMaxLength\n"
        "  Offset:         $targetNameOffset\n"
        "  Raw:            ${targetName.toList()}\n"
        "Negotiate Flags:  $negotiateFlags\n"
        "Server Challenge: ${serverChallenge.toList()}\n"
        "Reserved:         ${reserved.toList()}\n"
        "Target Info:      ${ascii.decode(targetInfo.toList(), allowInvalid: true)}\n"
        "  Length:         $targetInfoLength\n"
        "  Max Length:     $targetInfoMaxLength\n"
        "  Offset:         $targetInfoOffset\n"
        "  Raw:            ${targetInfo.toList()}\n"
        "---END TYPE 2 MESSAGE---";
  }
}

/// Extract the information from the type 2 [rawMsg] into an object.
Type2Message parseType2Message(List<int> buffer) {
  final buf = Uint8List.fromList(buffer).buffer;
  ByteData bufView = new ByteData.view(buf);
  Type2Message msg = new Type2Message();

  msg.signature = buf.asUint8List(0, 8);
  msg.type = bufView.getInt16(8, Endian.little);

  if (msg.type != 2) {
    throw new ArgumentError("A type 2 response was not passed!");
  }

  msg.targetNameLength = bufView.getInt16(12, Endian.little);
  msg.targetNameMaxLength = bufView.getInt16(14, Endian.little);
  msg.targetNameOffset = bufView.getInt32(16, Endian.little);
  msg.targetName = buf.asUint8List(msg.targetNameOffset, msg.targetNameLength);

  msg.negotiateFlags = bufView.getInt32(20, Endian.little);
  msg.serverChallenge = buf.asUint8List(24, 8);
  msg.reserved = buf.asUint8List(32, 8);

  if (msg.negotiateFlags & flags.NTLM_NegotiateTargetInfo != 0) {
    msg.targetInfoLength = bufView.getInt16(40, Endian.little);
    msg.targetInfoMaxLength = bufView.getInt16(42, Endian.little);
    msg.targetInfoOffset = bufView.getInt32(44, Endian.little);
    msg.targetInfo =
        buf.asUint8List(msg.targetInfoOffset, msg.targetInfoLength);
  }

  return msg;
}
