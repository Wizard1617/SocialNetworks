class News {
  int? newsId;
  String? description;
  int? likes;
  int? disLike;
  String? pictureId; // добавлено поле для идентификатора фотографии

  News({
    this.newsId,
    this.description,
    this.likes,
    this.disLike,
    this.pictureId,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['newsId'],
      description: json['description'],
      likes: json['likes'],
      disLike: json['disLike'],
      pictureId: json['pictureId'], // добавлено поле для идентификатора фотографии
    );
  }

  factory News.fromJsonWithLikesAndDislikes(Map<String, dynamic> json) {
    return News(
      newsId: json['newsId'],
      description: json['description'],
      likes: json['likes'],
      disLike: json['disLike'],
      pictureId: json['pictureId'],
    );
  }
}
