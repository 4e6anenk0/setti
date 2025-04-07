enum SaveMode {
  local, // Збереження локально
  session, // Збереження в сесії
  transitional, // Перехідне збереження
  custom // Власна логіка збереження
}

enum LoadMode { lazy, preload }
