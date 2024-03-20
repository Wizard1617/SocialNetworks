class MessageFile {
  final int iD_File;
  final String file_Url;

  MessageFile({
    required this.iD_File,
    required this.file_Url,
  });

  factory MessageFile.fromJson(Map<String, dynamic> json) {
    return MessageFile(
      iD_File: json['iD_File'],
      file_Url: json['file_Url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iD_File': iD_File,
      'file_Url': file_Url,
    };
  }
}
