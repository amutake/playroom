// リソースを表す型
case object Resource

// ワーカー <-> 調整者 の間で飛ぶメッセージを表す型
case object OK       // リソースの使用の許可
case object Finish   // リソースの使用が完了
case object Wait     // リソースの使用の待機
case object Request  // リソースの使用を要請

case object Start    // ワーカーのキック
