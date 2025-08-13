class SettingKey<T> {
  const SettingKey(this.id);

  final String id;

  @override
  bool operator ==(covariant SettingKey<T> other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
