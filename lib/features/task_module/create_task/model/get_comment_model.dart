class TaskCommentResponse {
  final List<TaskComment> content;
  final Pageable pageable;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;
  final Sort sort;
  final int numberOfElements;
  final bool first;
  final bool empty;

  TaskCommentResponse({
    required this.content,
    required this.pageable,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.size,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });

  factory TaskCommentResponse.fromJson(Map<String, dynamic> json) {
    return TaskCommentResponse(
      content: (json['content'] as List)
          .map((e) => TaskComment.fromJson(e))
          .toList(),
      pageable: Pageable.fromJson(json['pageable']),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      last: json['last'],
      size: json['size'],
      number: json['number'],
      sort: Sort.fromJson(json['sort']),
      numberOfElements: json['numberOfElements'],
      first: json['first'],
      empty: json['empty'],
    );
  }
}

class TaskComment {
  final String commentId;
  final String taskId;
  final String adminId;
  final String employeeId;
  final String commentedBy;
  final DateTime commentedAt;
  final String content;
  final List<CommentDoc> attachments;
  final bool deleted;

  TaskComment({
    required this.commentId,
    required this.taskId,
    required this.adminId,
    required this.employeeId,
    required this.commentedBy,
    required this.commentedAt,
    required this.content,
    required this.attachments,
    required this.deleted,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      commentId: json['commentId'],
      taskId: json['taskId'],
      adminId: json['adminId'],
      employeeId: json['employeeId'],
      commentedBy: json['commentedBy'],
      commentedAt: DateTime.parse(json['commentedAt']),
      content: json['content'],
      attachments: (json['attachments'] as List)
          .map((e) => CommentDoc.fromJson(e))
          .toList(),
      deleted: json['deleted'],
    );
  }
}

class CommentDoc {
  final String fileName;
  final String contentType;
  final String data;

  CommentDoc({
    required this.fileName,
    required this.contentType,
    required this.data,
  });

  factory CommentDoc.fromJson(Map<String, dynamic> json) {
    return CommentDoc(
      fileName: json['fileName'],
      contentType: json['contentType'],
      data: json['data'],
    );
  }
}

class Pageable {
  final int pageNumber;
  final int pageSize;
  final Sort sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      sort: Sort.fromJson(json['sort']),
      offset: json['offset'],
      paged: json['paged'],
      unpaged: json['unpaged'],
    );
  }
}

class Sort {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  Sort({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sorted: json['sorted'],
      empty: json['empty'],
      unsorted: json['unsorted'],
    );
  }
}
