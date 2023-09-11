import 'package:smb2/src/tools/ntlm/type1.dart';
import 'package:smb2/src/tools/ntlm/type2.dart';
import 'package:smb2/src/tools/ntlm/type3.dart';
import 'package:smb2/src/tools/smb_message.dart';

import 'base.dart';

/*
  request: [
    ['StructureSize', 2, 25],
    ['Flags', 1, 0],
    ['SecurityMode', 1, 1],
    ['Capabilities', 4, 1],
    ['Channel', 4, 0],
    ['SecurityBufferOffset', 2, 88],
    ['SecurityBufferLength', 2],
    ['PreviousSessionId', 8, 0],
    ['Buffer', 'SecurityBufferLength'],
  ],

  response: [
    ['StructureSize', 2],
    ['SessionFlags', 2],
    ['SecurityBufferOffset', 2],
    ['SecurityBufferLength', 2],
    ['Buffer', 'SecurityBufferLength'],
  ],
*
* */

class SessionSetup extends Structure {
  @override
  Map<String, dynamic> headers = {
    'Command': 'SESSION_SETUP',
  };

  @override
  List<Field> request = [
    Field('StructureSize', 2, defaultValue: 25),
    Field('Flags', 1),
    Field('SecurityMode', 1, defaultValue: 1),
    Field('Capabilities', 4, defaultValue: 1),
    Field('Channel', 4),
    Field('SecurityBufferOffset', 2, defaultValue: 88),
    Field('SecurityBufferLength', 2),
    Field('PreviousSessionId', 8, defaultValue: 0),
    Field('Buffer', 0, dynamicLength: 'SecurityBufferLength'),
  ];

  @override
  List<Field> response = [
    Field('StructureSize', 2),
    Field('SessionFlags', 2),
    Field('SecurityBufferOffset', 2),
    Field('SecurityBufferLength', 2),
    Field('Buffer', 0, dynamicLength: 'SecurityBufferLength'),
  ];
}

class SessionSetupStep1 extends SessionSetup {
  @override
  List<int> getBuffer([Map<String, dynamic>? data]) {
    final buf = createType1Message(
        hostname: this.connection.ip, ntdomain: this.connection.domain);
    Map<String, dynamic> data = {
//      'SecurityBufferLength': buf.length,
      'Buffer': buf,
    };
    return super.getBuffer(data);
  }

  @override
  String successCode = 'STATUS_MORE_PROCESSING_REQUIRED';

  onSuccess(SMBMessage msg) {
    connection.sessionId = msg.header['SessionId'];
    final t2msg = parseType2Message(msg.data['Buffer']);
    connection.type2Message = t2msg;
    connection.nonce = t2msg.serverChallenge.toList();
  }
}

class SessionSetupStep2 extends SessionSetup {
  @override
  String successCode = 'STATUS_SUCCESS';

  @override
  List<int> getBuffer([Map<String, dynamic>? data]) {
    final buf = createType3Message(this.connection.type2Message,
        hostname: this.connection.ip,
        domain: this.connection.domain,
        password: this.connection.password,
        username: this.connection.username);
    Map<String, dynamic> data = {
      'Buffer': buf,
    };
    return super.getBuffer(data);
  }
}
