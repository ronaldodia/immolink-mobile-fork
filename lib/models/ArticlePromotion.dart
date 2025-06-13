import 'package:immolink_mobile/models/Article.dart';

class ArticlePromotion {
  final int id;
  final int articleId;
  final String? startDate;
  final String? endDate;
  final String? amount;
  final String? status;
  final String? paymentStatus;
  final int? prospectsCount;
  final String? payedBy;
  final Article? article;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ArticlePromotion({
    required this.id,
    required this.articleId,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.prospectsCount,
    required this.payedBy,
    this.article,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticlePromotion.fromJson(Map<String, dynamic> json) {
    return ArticlePromotion(
      id: json['id'] as int? ?? 0,
      articleId: json['article_id'] as int? ?? 0,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      amount: json['amount']?.toString(),
      status: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      prospectsCount: json['prospects_count'] as int?,
      payedBy: json['payed_by'] as String?,
      article: json['article'] != null
          ? Article.fromJson(json['article'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
