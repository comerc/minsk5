import 'package:graphql_flutter/graphql_flutter.dart';
import './fragments.dart';

mixin Mutations {
  static final upsertMember = gql(r'''
    mutation UpsertMember($display_name: String $photo_url: String) {
      insert_member(objects: {display_name: $display_name, photo_url: $photo_url}, 
      on_conflict: {constraint: member_pkey, update_columns: [display_name, photo_url]}) {
        affected_rows
        returning {
          id
        }
      }
    }
  ''');

  static final insertSuggestion = gql(r'''
    mutation InsertSuggestion($unit_id: uuid $question: question_enum) {
      insert_suggestion(objects: {unit_id: $unit_id, question: $question}) {
        affected_rows
      }
    }
  ''');

  static final upsertModeration = gql(r'''
    mutation UpsertModeration($unit_id: uuid $claim: claim_enum) {
      insert_moderation(objects: {unit_id: $unit_id, claim: $claim}, 
      on_conflict: {constraint: moderation_pkey, update_columns: claim}) {
        affected_rows
      }
    }
  ''');

  static final insertUnit = gql(r'''
    mutation InsertUnit(
      $images: jsonb
      $text: String
      $urgent: urgent_enum
      $kind: kind_enum
      $location: geography
      $address: String
    ) {
      insert_unit_one(object: {
        images: $images
        text: $text
        urgent: $urgent
        kind: $kind
        location: $location
        address: $address
      }) {
        ...UnitFields
      }
    }
  ''')..definitions.addAll(Fragments.fragments.definitions);

  static final deleteUnit = gql(r'''
    mutation DeleteUnit($id: uuid) {
      update_unit(where: {id: {_eq: $id}}, _set: {is_blocked: true}) {
        affected_rows
      }
    }
  ''');

  static final upsertBlock = gql(r'''
    mutation UpsertBlock($member_id: uuid, $value: Boolean) {
      insert_block_one(object: {member_id: $member_id, value: $value},
      on_conflict: {constraint: block_pkey, update_columns: [value]}) {
        updated_at
      }
    }
  ''');

  // static final insertBlock = gql(r'''
  //   mutation InsertBlock($member_id: uuid) {
  //     insert_block_one(object: {member_id: $member_id}) {
  //       created_at
  //     }
  //   }
  // ''');

  // static final deleteBlock = gql(r'''
  //   mutation DeleteBlock($member_id: uuid) {
  //     delete_block(where: {member_id: {_eq: $member_id}}) {
  //       affected_rows
  //     }
  //   }
  // ''');

  static final upsertWish = gql(r'''
    mutation UpsertWish($unit_id: uuid, $value: Boolean) {
      insert_wish_one(object: {unit_id: $unit_id, value: $value},
      on_conflict: {constraint: wish_pkey, update_columns: [value]}) {
        updated_at
      }
    }
  ''');

  // static final insertWish = gql(r'''
  //   mutation InsertWish($unit_id: uuid) {
  //     insert_wish_one(object: {unit_id: $unit_id}) {
  //       created_at
  //     }
  //   }
  // ''');

  // static final deleteWish = gql(r'''
  //   mutation DeleteWish($unit_id: uuid) {
  //     delete_wish(where: {unit_id: {_eq: $unit_id}}) {
  //       affected_rows
  //     }
  //   }
  // ''');
}
