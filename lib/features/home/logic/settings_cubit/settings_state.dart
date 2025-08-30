class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {}

class SettingsUpdated extends SettingsState {
  final String message;

  SettingsUpdated(this.message);
}

class SettingsEditedData extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}
