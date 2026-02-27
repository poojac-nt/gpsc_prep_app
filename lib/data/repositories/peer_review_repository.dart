import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';
import 'package:gpsc_prep_app/domain/entities/peer_review_model.dart';

class PeerReviewRepository {
  final SupabaseHelper _supabaseHelper;

  PeerReviewRepository(this._supabaseHelper);

  Future<Either<Failure, List<PeerReviewModel>>> peerReview({
    required int testId,
    required int questionId,
  }) async {
    return await _supabaseHelper.peerReview(
      testId: testId,
      questionId: questionId,
    );
  }

  Future<Either<Failure, DetailedPeerReviewModel>> detailedPeerReview({
    required int answerId,
  }) async {
    return await _supabaseHelper.detailedPeerReview(answerId: answerId);
  }
}
