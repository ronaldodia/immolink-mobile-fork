import 'package:immolink_mobile/models/Article.dart';

class ArticlePromotion {
  final int id;
  final int articleId;
  final String startDate;
  final String endDate;
  final String amount;
  final String status;
  final String paymentStatus;
  final int prospectsCount;
  final Article? article; // Article peut être null

  ArticlePromotion({
    required this.id,
    required this.articleId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.prospectsCount,
    this.article, // Rendre optionnel
  });

  factory ArticlePromotion.fromJson(Map<String, dynamic> json) {
    return ArticlePromotion(
      id: json['id'],
      articleId: json['article_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      amount: json['amount'],
      status: json['status'],
      paymentStatus: json['payment_status'],
      prospectsCount: json['prospects_count'],
      article: json['article'] != null ? Article.fromJson(json['article']) : null, // Gestion du cas null
    );
  }
}
